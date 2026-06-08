import CoreML
import Vision

class MLModels {
    static let shared = MLModels()
    
    private var hazardDetector: VNCoreMLModel?
    private var personalItems: VNCoreMLModel?
    private var sceneClassifier: VNCoreMLModel?
    private var indoorObstaclesDetector: VNCoreMLModel?
    private var yolov8Model: VNCoreMLModel?
    
    private let hazardConfidenceThreshold: Float = 0.6
    private let personalItemsThreshold: Float = 0.7
    private let indoorObstaclesThreshold: Float = 0.65 // INCREASED - was detecting false positives
    private let yolov8Threshold: Float = 0.35 // LOWERED - to detect more objects
    private let visionClassifierThreshold: Float = 0.30 // LOWERED - for pens, lamps, etc.
    
    // NEW: Option to disable inaccurate IndoorObstacles model
    private let useIndoorObstaclesModel = true // SET TO FALSE - model is misclassifying
    
    private init() {
        print("🔄 MLModels initializing...")
        loadModels()
    }
    
    private func loadModels() {
        print("📦 Loading models from bundle...")
        
        do {
            // Load HazardDetector
            if let hazardURL = Bundle.main.url(forResource: "HazardDetector", withExtension: "mlmodelc") {
                let hazardModel = try MLModel(contentsOf: hazardURL)
                hazardDetector = try VNCoreMLModel(for: hazardModel)
                print("✅ HazardDetector loaded")
            }
            
            // Load PersonalObjectClassifier
            if let personalURL = Bundle.main.url(forResource: "PersonalObjectClassifier", withExtension: "mlmodelc") {
                let personalModel = try MLModel(contentsOf: personalURL)
                personalItems = try VNCoreMLModel(for: personalModel)
                print("✅ PersonalObjectClassifier loaded")
            }
            
            // Load SceneClassifier
            if let sceneURL = Bundle.main.url(forResource: "SceneClassifier", withExtension: "mlmodelc") {
                let sceneModel = try MLModel(contentsOf: sceneURL)
                sceneClassifier = try VNCoreMLModel(for: sceneModel)
                print("✅ SceneClassifier loaded")
            }
            
            // Load IndoorObstaclesDetector (but we may not use it)
            if let obstaclesURL = Bundle.main.url(forResource: "IndoorObstaclesDetector", withExtension: "mlmodelc") {
                let obstaclesModel = try MLModel(contentsOf: obstaclesURL)
                indoorObstaclesDetector = try VNCoreMLModel(for: obstaclesModel)
                if useIndoorObstaclesModel {
                    print("✅ IndoorObstaclesDetector loaded (10 classes)")
                } else {
                    print("⚠️ IndoorObstaclesDetector loaded but DISABLED (poor accuracy)")
                    print("   Will rely on YOLOv8 + Vision classifier instead")
                }
            } else if let obstaclesURL = Bundle.main.url(forResource: "IndoorObstaclesDetector", withExtension: "mlpackage") {
                let compiledURL = try MLModel.compileModel(at: obstaclesURL)
                let obstaclesModel = try MLModel(contentsOf: compiledURL)
                indoorObstaclesDetector = try VNCoreMLModel(for: obstaclesModel)
                if useIndoorObstaclesModel {
                    print("✅ IndoorObstaclesDetector loaded (10 classes)")
                } else {
                    print("⚠️ IndoorObstaclesDetector loaded but DISABLED (poor accuracy)")
                    print("   Will rely on YOLOv8 + Vision classifier instead")
                }
            }
            
            // Load YOLOv8
            loadYOLOv8Model()
            
        } catch {
            print("❌ Error loading models: \(error)")
        }
    }
    
    // COCO class names for YOLOv8n (80 classes, index-ordered)
    private let cocoClassNames = [
        "person", "bicycle", "car", "motorcycle", "airplane", "bus", "train", "truck", "boat",
        "traffic light", "fire hydrant", "stop sign", "parking meter", "bench", "bird", "cat",
        "dog", "horse", "cow", "elephant", "bear", "zebra", "giraffe", "backpack", "umbrella",
        "handbag", "tie", "suitcase", "frisbee", "skis", "snowboard", "sports ball", "kite",
        "baseball bat", "baseball glove", "skateboard", "surfboard", "tennis racket", "bottle",
        "wine glass", "cup", "fork", "knife", "spoon", "bowl", "banana", "apple", "sandwich",
        "orange", "broccoli", "carrot", "hot dog", "pizza", "donut", "cake", "chair", "couch",
        "potted plant", "bed", "dining table", "toilet", "tv", "laptop", "mouse", "remote",
        "keyboard", "cell phone", "microwave", "oven", "toaster", "sink", "refrigerator", "book",
        "clock", "vase", "scissors", "teddy bear", "hair drier", "toothbrush"
    ]

    private func loadYOLOv8Model() {
        // Use Bundle(for:) which correctly locates resources in Swift Playground apps
        let bundle = Bundle(for: yolov8n.self)
        guard let yoloURL = bundle.url(forResource: "yolov8n", withExtension: "mlmodelc") else {
            print("⚠️ YOLOv8 model not found - will use Vision classifier only")
            return
        }
        do {
            let mlModel = try MLModel(contentsOf: yoloURL)
            yolov8Model = try VNCoreMLModel(for: mlModel)
            print("✅ YOLOv8 loaded - 80 COCO classes")
        } catch {
            print("❌ Error loading YOLOv8: \(error)")
        }
    }
    
    // MARK: - Detection Methods
    
    func detectHazards(in image: CVPixelBuffer, completion: @escaping ([DetectionResult]) -> Void) {
        guard let model = hazardDetector else {
            completion([])
            return
        }
        
        let request = VNCoreMLRequest(model: model) { (request: VNRequest, error: Error?) in
            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                completion([])
                return
            }
            
            let detections = results
                .filter { $0.confidence >= self.hazardConfidenceThreshold }
                .compactMap { observation -> DetectionResult? in
                    guard let label = observation.labels.first?.identifier else { return nil }
                    return DetectionResult(
                        label: label,
                        confidence: observation.confidence,
                        boundingBox: observation.boundingBox,
                        distance: nil,
                        direction: self.getDirection(from: observation.boundingBox),
                        modelSource: .hazard
                    )
                }
            
            if !detections.isEmpty {
                print("🚨 Hazards: \(detections.map { "\($0.label) \(Int($0.confidence * 100))%" })")
            }
            completion(detections)
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        try? handler.perform([request])
    }
    
    func detectIndoorObstacles(in image: CVPixelBuffer, completion: @escaping ([DetectionResult]) -> Void) {
        // DISABLED if model is inaccurate
        guard useIndoorObstaclesModel, let model = indoorObstaclesDetector else {
            completion([])
            return
        }
        
        let request = VNCoreMLRequest(model: model) { (request: VNRequest, error: Error?) in
            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                completion([])
                return
            }
            
            let detections = results
                .filter { $0.confidence >= self.indoorObstaclesThreshold }
                .map { observation in
                    let label = observation.labels.first?.identifier ?? "object"
                    let friendlyLabel = self.getFriendlyLabel(for: label)
                    
                    return DetectionResult(
                        label: friendlyLabel,
                        confidence: observation.confidence,
                        boundingBox: observation.boundingBox,
                        distance: nil,
                        direction: self.getDirection(from: observation.boundingBox),
                        modelSource: .indoorObstacles
                    )
                }
            
            if !detections.isEmpty {
                print("🏠 Indoor Obstacles: \(detections.map { "\($0.label) \(Int($0.confidence * 100))%" })")
            }
            completion(detections)
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        try? handler.perform([request])
    }
    
    // IMPROVED: YOLOv8 with better filtering
    func detectWithYOLO(in image: CVPixelBuffer, completion: @escaping ([DetectionResult]) -> Void) {
        guard let model = yolov8Model else {
            print("⚠️ YOLOv8 not loaded, using Vision classifier")
            detectWithVisionClassifier(in: image, completion: completion)
            return
        }
        
        let request = VNCoreMLRequest(model: model) { (request: VNRequest, error: Error?) in
            var yoloDetections: [DetectionResult] = []

            if let results = request.results as? [VNRecognizedObjectObservation], !results.isEmpty {
                // Vision-annotated model: standard bounding box observations
                let excludeList = Set([
                    "surfboard", "skateboard", "skis", "snowboard", "sports ball",
                    "baseball bat", "tennis racket", "frisbee", "kite",
                    "elephant", "bear", "zebra", "giraffe", "horse", "cow", "sheep",
                    "bicycle", "motorcycle", "airplane", "boat", "train", "truck"
                ])
                yoloDetections = results
                    .filter { $0.confidence >= self.yolov8Threshold }
                    .compactMap { observation in
                        let label = observation.labels.first?.identifier ?? "object"
                        guard !excludeList.contains(label.lowercased()) else { return nil }
                        return DetectionResult(
                            label: label,
                            confidence: observation.confidence,
                            boundingBox: observation.boundingBox,
                            distance: nil,
                            direction: self.getDirection(from: observation.boundingBox),
                            modelSource: .yolo
                        )
                    }

            } else if let results = request.results as? [VNCoreMLFeatureValueObservation] {
                // Raw YOLOv8 output: confidence [N,80] + coordinates [N,4]
                yoloDetections = self.parseYOLOFeatureObservations(results)
            } else {
                print("⚠️ YOLOv8 returned no results")
            }

            if !yoloDetections.isEmpty {
                print("🎯 YOLOv8 detected: \(yoloDetections.map { "\($0.label) \(Int($0.confidence * 100))%" })")
            }

            // ALWAYS run Vision classifier to catch pens, lamps, and small objects
            self.detectWithVisionClassifier(in: image) { visionDetections in
                completion(yoloDetections + visionDetections)
            }
        }
        
        request.imageCropAndScaleOption = .scaleFill
        
        let handler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        try? handler.perform([request])
    }
    
    // CRITICAL: Vision classifier for pens, lamps, and other objects YOLO misses
    private func detectWithVisionClassifier(in image: CVPixelBuffer, completion: @escaping ([DetectionResult]) -> Void) {
        let request = VNClassifyImageRequest { (request: VNRequest, error: Error?) in
            guard let results = request.results as? [VNClassificationObservation] else {
                completion([])
                return
            }
            
            // Target objects
            let targetKeywords = [
                "laptop", "notebook", "computer", "macbook",
                "keyboard", "typewriter",
                "mouse", "trackpad",
                "monitor", "screen", "display",
                "lamp", "light", "lantern", "candle",
                "pen", "pencil", "ballpoint", "marker",
                "bottle", "water", "flask",
                "cup", "mug", "coffee", "glass",
                "book", "novel", "textbook",
                "phone", "telephone", "cellular", "mobile", "iphone",
                "remote", "controller",
                "clock", "watch", "timepiece",
                "door", "doorway", "entrance",
                "table", "desk",
                "chair", "seat",
                "bed", "mattress",
                "couch", "sofa"
            ]
            
            let detections = results
                .filter { observation in
                    let identifier = observation.identifier.lowercased()
                    return targetKeywords.contains { identifier.contains($0) }
                }
                .filter { $0.confidence >= self.visionClassifierThreshold }
                .prefix(6)
                .map { observation in
                    let cleanLabel = self.cleanClassifierLabel(observation.identifier)
                    
                    return DetectionResult(
                        label: cleanLabel,
                        confidence: observation.confidence,
                        boundingBox: nil,
                        distance: nil,
                        direction: .center,
                        modelSource: .yolo
                    )
                }
            
            if !Array(detections).isEmpty {
                print("🔍 Vision classifier detected: \(Array(detections).map { "\($0.label) \(Int($0.confidence * 100))%" })")
            } else {
                print("ℹ️ Vision classifier found no objects above \(Int(self.visionClassifierThreshold * 100))% confidence")
            }
            
            completion(Array(detections))
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        try? handler.perform([request])
    }
    
    // Parse raw YOLOv8 CoreML output (confidence [N,80], coordinates [N,4])
    private func parseYOLOFeatureObservations(_ observations: [VNCoreMLFeatureValueObservation]) -> [DetectionResult] {
        var confidenceArray: MLMultiArray?
        var coordinatesArray: MLMultiArray?

        for obs in observations {
            if obs.featureName == "confidence" {
                confidenceArray = obs.featureValue.multiArrayValue
            } else if obs.featureName == "coordinates" {
                coordinatesArray = obs.featureValue.multiArrayValue
            }
        }

        guard let conf = confidenceArray, let coords = coordinatesArray,
              conf.shape.count >= 2, coords.shape.count >= 2 else { return [] }

        let numBoxes   = conf.shape[0].intValue
        let numClasses = min(cocoClassNames.count, conf.shape[1].intValue)

        let excludeSet = Set([
            "surfboard", "skateboard", "skis", "snowboard", "sports ball",
            "baseball bat", "tennis racket", "frisbee", "kite",
            "elephant", "bear", "zebra", "giraffe", "horse", "cow", "sheep",
            "bicycle", "motorcycle", "airplane", "boat", "train", "truck"
        ])

        var results: [DetectionResult] = []

        for i in 0..<numBoxes {
            var maxConf: Float = 0
            var classIdx = 0

            for j in 0..<numClasses {
                let val = conf[[NSNumber(value: i), NSNumber(value: j)]].floatValue
                if val > maxConf { maxConf = val; classIdx = j }
            }

            guard maxConf >= yolov8Threshold, classIdx < cocoClassNames.count else { continue }
            let label = cocoClassNames[classIdx]
            guard !excludeSet.contains(label) else { continue }

            let cx = coords[[NSNumber(value: i), NSNumber(value: 0)]].floatValue
            let cy = coords[[NSNumber(value: i), NSNumber(value: 1)]].floatValue
            let w  = coords[[NSNumber(value: i), NSNumber(value: 2)]].floatValue
            let h  = coords[[NSNumber(value: i), NSNumber(value: 3)]].floatValue

            let box = CGRect(x: CGFloat(cx - w/2), y: CGFloat(cy - h/2),
                             width: CGFloat(w), height: CGFloat(h))

            results.append(DetectionResult(
                label: label,
                confidence: maxConf,
                boundingBox: box,
                distance: nil,
                direction: getDirection(from: box),
                modelSource: .yolo
            ))
        }

        return results
    }

    private func cleanClassifierLabel(_ label: String) -> String {
        let cleaned = label.lowercased()
            .components(separatedBy: ",").first ?? label.lowercased()
            .replacingOccurrences(of: "_", with: " ")
        
        // Direct mappings
        let mappings: [String: String] = [
            "notebook computer": "laptop",
            "portable computer": "laptop",
            "laptop computer": "laptop",
            "macbook": "laptop",
            "computer keyboard": "keyboard",
            "electric typewriter": "keyboard",
            "computer mouse": "mouse",
            "optical mouse": "mouse",
            "computer monitor": "monitor",
            "computer screen": "monitor",
            "desk lamp": "lamp",
            "table lamp": "lamp",
            "reading lamp": "lamp",
            "floor lamp": "lamp",
            "ballpoint": "pen",
            "water bottle": "bottle",
            "plastic bottle": "bottle",
            "coffee mug": "cup",
            "coffee cup": "cup",
            "cellular telephone": "phone",
            "mobile phone": "phone",
            "cell phone": "phone"
        ]
        
        for (pattern, replacement) in mappings {
            if cleaned.contains(pattern) {
                return replacement
            }
        }
        
        // Extract keywords
        let keywords = [
            "laptop", "keyboard", "mouse", "monitor", "lamp",
            "pen", "pencil", "bottle", "cup", "book", "phone",
            "remote", "clock", "door", "table", "chair", "bed", "couch"
        ]
        
        for keyword in keywords {
            if cleaned.contains(keyword) {
                return keyword
            }
        }
        
        return cleaned
    }
    
    func recognizePersonalItems(in image: CVPixelBuffer, completion: @escaping ([DetectionResult]) -> Void) {
        guard let model = personalItems else {
            completion([])
            return
        }
        
        let request = VNCoreMLRequest(model: model) { (request: VNRequest, error: Error?) in
            guard let results = request.results as? [VNClassificationObservation] else {
                completion([])
                return
            }
            
            let detections = results
                .filter { $0.confidence >= self.personalItemsThreshold && $0.identifier != "background" }
                .prefix(3)
                .map { observation in
                    DetectionResult(
                        label: observation.identifier,
                        confidence: observation.confidence,
                        boundingBox: nil,
                        distance: nil,
                        direction: .center,
                        modelSource: .personal
                    )
                }
            
            if !Array(detections).isEmpty {
                print("👤 Personal items: \(Array(detections).map { "\($0.label) \(Int($0.confidence * 100))%" })")
            }
            completion(Array(detections))
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        try? handler.perform([request])
    }
    
    func classifyScene(in image: CVPixelBuffer, completion: @escaping (String?) -> Void) {
        guard let model = sceneClassifier else {
            completion(nil)
            return
        }
        
        let request = VNCoreMLRequest(model: model) { (request: VNRequest, error: Error?) in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                completion(nil)
                return
            }
            
            print("🏠 Scene: \(topResult.identifier) (\(Int(topResult.confidence * 100))%)")
            completion(topResult.identifier)
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        try? handler.perform([request])
    }
    
    // MARK: - Priority Detection
    
    func detectWithPriority(in image: CVPixelBuffer, completion: @escaping ([DetectionResult], String?) -> Void) {
        var finalDetections: [DetectionResult] = []
        var sceneResult: String?
        
        let group = DispatchGroup()
        
        // PRIORITY 1: Hazards
        group.enter()
        detectHazards(in: image) { hazards in
            if !hazards.isEmpty {
                print("🚨 HAZARD DETECTED - Priority override")
                finalDetections = hazards
                group.leave()
                
                self.classifyScene(in: image) { scene in
                    sceneResult = scene
                }
                return
            }
            group.leave()
            
            // PRIORITY 2: Indoor Obstacles (DISABLED if inaccurate)
            if self.useIndoorObstaclesModel {
                group.enter()
                self.detectIndoorObstacles(in: image) { obstacles in
                    finalDetections.append(contentsOf: obstacles)
                    group.leave()
                }
            }
            
            // PRIORITY 3: YOLOv8 + Vision Classifier (COMBINED)
            group.enter()
            self.detectWithYOLO(in: image) { combinedObjects in
                print("🔍 Combined detection returned \(combinedObjects.count) objects")
                finalDetections.append(contentsOf: combinedObjects)
                group.leave()
            }
            
            // PRIORITY 4: Personal items
            group.enter()
            self.recognizePersonalItems(in: image) { personalItems in
                finalDetections.append(contentsOf: personalItems)
                group.leave()
            }
            
            // PRIORITY 5: Scene
            group.enter()
            self.classifyScene(in: image) { scene in
                sceneResult = scene
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            let deduplicated = self.deduplicateDetections(finalDetections)
            let sorted = deduplicated
                .sorted { $0.confidence > $1.confidence }
                .prefix(10)
            
            print("📊 Final detections: \(Array(sorted).map { "\($0.label) \(Int($0.confidence * 100))%" })")
            
            completion(Array(sorted), sceneResult)
        }
    }
    
    // MARK: - Helper Methods
    
    private func deduplicateDetections(_ detections: [DetectionResult]) -> [DetectionResult] {
        var seen: Set<String> = []
        var result: [DetectionResult] = []
        
        for detection in detections {
            let key = detection.label.lowercased()
            
            if !seen.contains(key) {
                seen.insert(key)
                result.append(detection)
            }
        }
        
        return result
    }
    
    private func getFriendlyLabel(for label: String) -> String {
        switch label.lowercased() {
        case "door": return "door"
        case "openeddoor": return "open door"
        case "cabinetdoor": return "cabinet door"
        case "refrigeratordoor": return "refrigerator door"
        case "window": return "window"
        case "chair": return "chair"
        case "table": return "table"
        case "cabinet": return "cabinet"
        case "couch": return "couch"
        case "pole": return "pole"
        default: return label
        }
    }
    
    private func getDirection(from box: CGRect) -> DetectionResult.Direction {
        let centerX = box.midX
        
        if centerX < 0.33 {
            return .left
        } else if centerX > 0.67 {
            return .right
        } else {
            return .center
        }
    }
}
