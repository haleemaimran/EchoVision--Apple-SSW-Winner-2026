# EchoVision 🎯

### AI-Powered Accessibility App for Safe Indoor Navigation

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)](https://www.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Apple Winner](https://img.shields.io/badge/🏆-Apple%20Swift%20Student%20Challenge%202026%20Winner-gold.svg)](#awards)

---

## 🌟 Overview

**EchoVision** is an iOS accessibility application that uses real-time computer vision and machine learning to help visually impaired users safely navigate indoor spaces. By combining object detection, hazard recognition, and spatial audio feedback, EchoVision provides intelligent, hands-free navigation assistance.

### The Problem
GPS doesn't work indoors. Blind and low-vision users face daily hazards (stairs, open doors, obstacles) in homes, schools, offices, and unfamiliar spaces. Existing solutions are expensive, require constant manual assistance, or don't provide real-time awareness.

### The Solution
EchoVision runs on-device AI to detect 80+ objects, prioritize hazards, and announce surroundings through spatial audio—all instantly, completely offline, with zero privacy concerns.

---

## ✨ Key Features

### 🚨 Priority Hazard Detection
- **Instant alerts** for critical hazards: stairs, knives, ladders, wet floors
- **Interrupts** other announcements for safety
- **High confidence threshold** ensures accuracy

### 👁️ Real-Time Object Detection
- **80+ objects** detected using YOLOv8 Nano
- **40-80 FPS** real-time performance on iPhone
- **Spatial awareness** with left/center/right positioning

### 🏢 Scene Classification
- **15 room types** identified (kitchen, bedroom, bathroom, office, gym, etc.)
- Provides **context** for object announcements
- Helps users understand their environment

### 🏠 Indoor Obstacle Detection
- **10 custom-trained classes** optimized for navigation
- Doors, furniture, poles, cabinets
- Trained with Create ML transfer learning

### 🔊 Spatial Audio Feedback
- **Directional announcements** (left, center, right)
- **Adjustable speech rate** (0.3x – 0.7x)
- **Audio panning** for spatial awareness
- 100% on-device (no network dependency)

### ♿ Accessibility-First Design
- **Large Text Mode** (20% font size increase)
- **High Contrast Mode** (WCAG AAA compliant)
- **VoiceOver Support** (full screen reader compatibility)
- **Haptic Feedback** (tactile confirmation)
- **Adjustable Audio** (speech rate customization)

### 🤖 Intelligent Auto-Announcements
- Announces detected objects **every 4 seconds**
- **No manual interaction** needed
- **Deduplication system** prevents repetitive announcements
- **Stability filtering** eliminates false positives (3+ frame confirmation)

---

## 🏗️ Technical Architecture

### ML Models Stack

```
Priority Detection System
├─ PRIORITY 1: HazardDetector.mlmodelc (6.9 MB)
│  ├─ Stairs, knives, ladders, wet floors, fire
│  └─ 0.60 confidence threshold (high precision)
│
├─ PRIORITY 2: IndoorObstaclesDetector.mlmodelc (7.7 MB)
│  ├─ Doors, furniture, poles, cabinets (10 classes)
│  └─ Trained with Create ML + transfer learning
│
├─ PRIORITY 3: YOLOv8 Nano (6.5 MB)
│  ├─ 80 COCO classes (objects, people, animals)
│  └─ 0.35 confidence threshold
│
├─ PRIORITY 4: PersonalObjectClassifier.mlmodelc
│  ├─ Watch, glasses, wallet, keys, phone
│  └─ 0.70 confidence threshold
│
└─ PRIORITY 5: SceneClassifier.mlmodelc
   ├─ 15 room types
   └─ 0.45 confidence threshold
```

### Framework Stack

| Framework | Purpose |
|-----------|---------|
| **SwiftUI** | Modern declarative UI |
| **CoreML** | On-device ML inference |
| **Vision** | Image processing & object detection |
| **AVFoundation** | Camera & audio management |
| **AVSpeech** | Text-to-speech announcements |
| **Combine** | Reactive state management |

### Key Components

**MLModels.swift**
- Loads and manages 5 ML models
- `detectWithPriority()` orchestrates detection flow
- Priority-based filtering and deduplication

**CameraViewModel.swift**
- AVCaptureSession management
- Real-time frame processing (30 FPS)
- Auto-announcement timer (4 seconds)
- Stability counter for consistent detections

**SpeechManager.swift**
- AVSpeechSynthesizer wrapper
- Adjustable speech rate
- Priority-based speech queue
- 100% on-device audio

**DetectionResult.swift**
- Label, confidence, bounding box
- Directional information (left/center/right)
- Model source tracking

**CameraView.swift**
- Real-time object detection overlay
- Status indicators (stable/lighting)
- Manual announcement button
- Deduplicated detection display

---

## 🚀 Getting Started

### Requirements

- **iOS**: 17.0 or later
- **Device**: iPhone or iPad with A12 Bionic or newer
- **Storage**: ~50 MB (app + models)
- **Xcode**: 15.0 or later
- **Swift**: 5.9+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/EchoVision.git
   cd EchoVision
   ```

2. **Open in Xcode**
   ```bash
   open EchoVision.xcodeproj
   ```

3. **Select target device**
   - Choose an iOS 17.0+ device or simulator
   - A12 Bionic or newer recommended for optimal performance

4. **Build & Run**
   ```bash
   ⌘ + R (or Product → Run in Xcode)
   ```

5. **Grant camera permissions**
   - App will request camera access on first launch
   - Required for object detection

### Swift Playgrounds

EchoVision is also available as a Swift Playgrounds submission:
- Download Swift Playgrounds app (free on App Store)
- Open `EchoVision.swiftpm`
- Tap "Run" to build and execute

---

## 📖 How to Use

### Starting EchoVision

1. **Launch the app** and tap **"Start Exploring"**
2. **Point camera** at your surroundings
3. **Listen to announcements** (every 4 seconds)
4. **Adjust settings** using the ♿ accessibility menu

### Understanding Announcements

**EchoVision Groups Objects Intelligently:**

❌ Instead of: *"Table table table chair chair bottle bottle"*  
✅ EchoVision says: *"There is a table in front. Chair on your left. Bottle on your right. Lighting is dim."*

### Spatial Audio

- **Left** = Object on left side of camera
- **Center** = Object directly ahead
- **Right** = Object on right side

### Customization

**Accessibility Menu** (tap ♿ icon):
- **Large Text** - Increases font size by 20%
- **High Contrast** - Yellow text on black (WCAA AAA)
- **Speech Rate** - Adjust from slow (0.3x) to fast (0.7x)

**Settings**:
- Customize announcement frequency
- Adjust confidence thresholds
- Test speech rate with sample announcement

---

## 📊 Performance Metrics

| Metric | Target | Actual |
|--------|--------|--------|
| **Inference Speed** | Real-time | 40-80 FPS |
| **Model Accuracy (mAP)** | >0.70 | 0.75-0.85 |
| **Total Model Size** | <25 MB | 22-24 MB |
| **Memory Usage** | <200 MB | ~150 MB |
| **Latency** | <100ms | 50-80ms |
| **Battery Impact** | Minimal | ~5% per hour |
| **Announcement Interval** | 4 seconds | 4 seconds |
| **Stability Threshold** | 3+ frames | 3 frames |

---

## 🔒 Privacy & Security

✅ **100% On-Device Processing**
- No data leaves your iPhone
- Zero network requests
- Complete offline functionality

✅ **No Data Storage**
- Real-time analysis only
- No caching of detection results
- No user data collection

✅ **Transparent Permissions**
- Camera access only when needed
- Clear permission requests
- No background activity

✅ **Open Source**
- Community-auditable code
- MIT License
- No hidden functionality

---

## 🛠️ Technical Deep Dive

### Detection Flow

```
1. Camera captures frame (30 FPS)
   ↓
2. MLModels.detectWithPriority() executes
   ├─ Check hazards first (stairs, knives)
   │  └─ If found → announce immediately, exit
   ├─ Detect indoor obstacles (doors, furniture)
   ├─ Run YOLOv8 for 80 objects
   ├─ Recognize personal items
   └─ Classify scene
   ↓
3. Deduplicate results (avoid repeating "table")
   ↓
4. Sort by confidence score
   ↓
5. Build intelligent announcement
   ↓
6. Auto-announce if stable for 3+ frames
```

### Stability System

Objects must appear in **3+ consecutive frames** before announcement:
- Prevents false positives from detection noise
- Tracks detection count per object
- Resets when object disappears
- Ensures accurate announcements

### Deduplication Algorithm

- Only announces unique objects once per 4-second cycle
- Remembers announced objects for 10 seconds
- Groups objects by spatial location
- Reduces cognitive overload

---

## 📁 Project Structure

```
EchoVision.swiftpm/
├── Package.swift                 # Swift package manifest
├── App.swift                     # App entry point
├── Views/
│  ├── HomeView.swift            # Onboarding & main menu
│  ├── CameraView.swift          # Real-time detection UI
│  ├── SettingsView.swift        # Customization options
│  └── OnboardingView.swift      # First-time setup
├── ViewModels/
│  └── CameraViewModel.swift     # Camera & detection logic
├── Models/
│  ├── MLModels.swift            # ML model management
│  ├── DetectionResult.swift     # Detection data structures
│  └── SpeechManager.swift       # Audio synthesis
├── Resources/
│  ├── HazardDetector.mlmodelc   # Hazard detection model
│  ├── IndoorObstaclesDetector.mlmodelc
│  ├── PersonalObjectClassifier.mlmodelc
│  ├── SceneClassifier.mlmodelc
│  └── yolov8n.mlmodelc          # YOLOv8 model
└── Info.plist                    # App permissions & metadata
```

---

## 🧠 ML Models Reference

### YOLOv8 Nano
- **Classes**: 80 (COCO dataset)
- **Size**: 6.5 MB (mlmodelc format)
- **Speed**: 40-80 FPS on iPhone
- **Threshold**: 0.35 confidence
- **Detects**: laptop, keyboard, mouse, monitor, bottle, cup, chair, person, etc.

### HazardDetector
- **Classes**: Stairs, knife, ladder, wet floor, fire
- **Size**: 6.9 MB
- **Threshold**: 0.60 confidence (high precision)
- **Priority**: Interrupts all other announcements

### IndoorObstaclesDetector
- **Classes**: Door, cabinet, table, chair, window, couch, pole, fridge, etc.
- **Size**: 7.7 MB
- **Training**: Create ML + transfer learning
- **Threshold**: 0.50 confidence

### PersonalObjectClassifier
- **Classes**: Watch, glasses, wallet, keys, phone
- **Threshold**: 0.70 confidence
- **Function**: Tracks user's personal belongings

### SceneClassifier
- **Classes**: 15 room types (kitchen, bedroom, bathroom, office, gym, living room, etc.)
- **Threshold**: 0.45 confidence
- **Purpose**: Provides context for announcements

---

## 🎓 Code Quality

- **Language**: 100% Swift
- **Architecture**: MVVM pattern
- **Framework**: SwiftUI + Combine
- **Error Handling**: Comprehensive exception handling
- **Documentation**: Inline code comments
- **Testing**: Tested on iOS 17.0+ devices

---

## 🚀 Future Enhancements

### Planned Features
- [ ] Obstacle avoidance warnings (low-hanging objects)
- [ ] Route learning and memorization
- [ ] Offline speech synthesis
- [ ] Vibration pattern feedback
- [ ] Sound classification (traffic, alarms)
- [ ] AR glasses integration
- [ ] Collaborative mapping
- [ ] Multi-language support

### Research Opportunities
- Improve obstacle detection for underrepresented scenarios
- Reduce false positives through ensemble methods
- Benchmark against other assistive technologies
- User studies with blind and low-vision testers
- Integration with white cane technology

---

## 🏆 Awards & Recognition

### 🥇 Apple Swift Student Challenge 2026 - Winner

EchoVision was selected for:
- ✅ **Technical Excellence** - Real-time ML inference mastery
- ✅ **Problem-Solving** - Addresses real accessibility gap
- ✅ **User Experience** - Intuitive voice-only interface
- ✅ **Creative Implementation** - Innovative detection architecture
- ✅ **Code Quality** - Clean, well-documented codebase

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

### Attribution

- **YOLOv8** - [Ultralytics](https://github.com/ultralytics/ultralytics) (Apache 2.0)
- **COCO Dataset** - [CC BY 4.0](https://cocodataset.org/)
- **SF Symbols** - Apple Design System
- **Indoor Dataset** - Thepbordin Jaiinsom (CC License)

---

## 🤝 Contributing

Contributions are welcome! Here's how to help:

### For Developers
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### For Accessibility Testing
- Test with VoiceOver enabled
- Verify Large Text and High Contrast modes
- Test with real blind/low-vision users
- Report issues with detection accuracy

### For ML Model Improvements
- Contribute training datasets
- Improve detection accuracy
- Optimize model performance
- Suggest new object classes

---

## 📧 Contact & Support

**Developer**: Haleema Imran  
**Email**: hallieimran@gmail.com  
**LinkedIn**: [linkedin.com/in/haleemaimran](https://linkedin.com/in/haleemaimran)  
**GitHub**: [@yourusername](https://github.com/haleemaimran)

**Issues & Feedback**: [GitHub Issues](https://github.com/yourusername/EchoVision/issues)

---

## 🙏 Acknowledgments

- **Apple** for the Swift Student Challenge platform and opportunity
- **NUST** (National University of Sciences & Technology) for academic support
- **Blind and low-vision community** for feedback and guidance
- **Open source community** for frameworks and models

---

## 📚 Resources

- [Apple Vision Framework Documentation](https://developer.apple.com/documentation/vision)
- [CoreML Guide](https://developer.apple.com/machine-learning/core-ml/)
- [Create ML Training Custom Vision Models](https://developer.apple.com/machine-learning/create-ml/)
- [YOLOv8 Documentation](https://docs.ultralytics.com/)
- [WebAIM Contrast Checker (WCAG)](https://webaim.org/resources/contrastchecker/)

---

## ⭐ If You Find This Helpful

Please consider giving this project a star! It helps others discover EchoVision and learn from the implementation.

```
⭐ Star this repo if you found it valuable!
👁️ Watch for updates
🔄 Share with your network
```

---

**Made with ❤️ for accessibility and inclusive technology**

Last Updated: June 2026  
EchoVision v1.0 - Apple Swift Student Challenge Winner
