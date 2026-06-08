# Contributing to EchoVision 🎯

Thank you for your interest in contributing to EchoVision! This project aims to improve accessibility through technology, and we welcome contributions from developers, accessibility experts, and the blind/low-vision community.

---

## 🎯 Our Mission

EchoVision exists to help visually impaired users navigate the world safely and independently. Every contribution should keep this goal in mind.

---

## 📋 Ways to Contribute

### 🐛 Report Bugs
Found an issue? Please help us fix it!

1. Check [existing issues](https://github.com/yourusername/EchoVision/issues) to avoid duplicates
2. Create a new issue with:
   - **Title**: Clear, descriptive (e.g., "YOLOv8 crashes on iPhone 12 with low memory")
   - **Device**: iPhone model and iOS version
   - **Steps to Reproduce**: Exact steps that cause the issue
   - **Expected vs Actual**: What should happen vs what actually happens
   - **Screenshots/Video**: If applicable

### 💡 Suggest Features
Have an idea for improvement?

1. Check [discussions](https://github.com/yourusername/EchoVision/discussions)
2. Propose features that benefit accessibility
3. Explain the use case and expected impact
4. Examples:
   - "Add obstacle avoidance warnings for low-hanging objects"
   - "Improve scene classification accuracy for outdoor spaces"
   - "Support Bluetooth hearing aid integration"

### 👁️ Accessibility Testing
Test the app and report accessibility issues:

- Test with **VoiceOver** enabled
- Verify **Large Text** and **High Contrast** modes
- Test **speech rate adjustments**
- Report touch target sizes and gesture support
- Suggest improvements for blind/low-vision users

### 📚 Documentation
Help improve documentation:

- Fix typos and clarify instructions
- Add examples and tutorials
- Create guides for common use cases
- Translate documentation to other languages

### 💻 Code Contributions
Submit pull requests with improvements:

---

## 🚀 Getting Started with Code Contributions

### 1. Fork & Clone

```bash
# Fork on GitHub, then clone your fork
git clone https://github.com/YOUR_USERNAME/EchoVision.git
cd EchoVision
git remote add upstream https://github.com/yourusername/EchoVision.git
```

### 2. Create a Feature Branch

```bash
# Update from upstream
git fetch upstream
git checkout upstream/main

# Create your feature branch
git checkout -b feature/your-feature-name
```

### 3. Make Your Changes

- Keep commits small and focused
- Write clear commit messages: `Add real-time hazard detection improvement`
- Follow Swift style guide (see below)
- Add comments for complex logic

### 4. Test Your Changes

```bash
# Build in Xcode
⌘ + B

# Run on device or simulator
⌘ + R

# Test accessibility features
# - Enable VoiceOver (Settings > Accessibility > VoiceOver)
# - Test Large Text mode
# - Test High Contrast mode
# - Test with actual blind/low-vision users if possible
```

### 5. Push & Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then open a Pull Request on GitHub with:
- **Title**: What does this change do?
- **Description**: Why is this change needed?
- **Testing**: How should reviewers test this?
- **Screenshots**: Before/after if UI changed

---

## 🎨 Code Style & Standards

### Swift Style Guide

Follow [Apple's Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/):

```swift
// ✅ Good: Descriptive, clear intent
func detectHazardsWithPriority(in frame: CVPixelBuffer) -> [DetectionResult] {
    // Implementation
}

// ❌ Bad: Vague, unclear
func detect(f: CVPixelBuffer) -> [DetectionResult] {
    // Implementation
}
```

### Naming Conventions

```swift
// Classes: PascalCase
class CameraViewController { }

// Functions: camelCase
func detectObjects() { }

// Variables: camelCase
let detectionResults = []
var currentFrame: CVPixelBuffer?

// Constants: camelCase (not UPPER_CASE)
let hazardConfidenceThreshold: Float = 0.60

// Booleans: start with is/has/should
var isStable = true
var hasHazard = false
var shouldAnnounce = true
```

### Comments & Documentation

```swift
/// Detects hazards in the given frame using priority-based ML models.
///
/// This function runs hazard detection first (highest priority), then
/// other models. If a hazard is found, it immediately returns without
/// running other detections.
///
/// - Parameter frame: The camera frame to analyze
/// - Returns: Array of detected hazards (usually 0 or 1)
/// - Complexity: O(n) where n is number of detections
func detectHazards(in frame: CVPixelBuffer) -> [DetectionResult] {
    // Implementation
}
```

### Error Handling

```swift
// ✅ Good: Explicit error handling
do {
    let result = try MLModels.shared.detect(in: frame)
    process(result)
} catch {
    logger.error("Detection failed: \(error)")
    fallbackDetection()
}

// ❌ Bad: Silent failures
let result = try? MLModels.shared.detect(in: frame)
process(result ?? []) // Crashes if nil
```

### MVVM Architecture

```
Views/
├── HomeView.swift           // UI only
├── CameraView.swift         # UI only
└── SettingsView.swift       # UI only

ViewModels/
└── CameraViewModel.swift    # Business logic, state

Models/
├── MLModels.swift           # ML inference
├── DetectionResult.swift    # Data structures
└── SpeechManager.swift      # Audio services
```

---

## ♿ Accessibility Guidelines

All contributions must maintain accessibility standards:

### WCAG AAA Compliance

- **Color Contrast**: Minimum 7:1 for text on background
- **Text Size**: Minimum 11pt, larger for headings
- **Touch Targets**: Minimum 44x44 points
- **Motion**: No autoplaying animations

### VoiceOver Support

```swift
// ✅ Good: Clear VoiceOver labels
Button(action: startExploring) {
    Label("Start Exploring", systemImage: "camera.fill")
}
.accessibilityLabel("Start Exploring")
.accessibilityHint("Begins real-time object detection")

// ❌ Bad: No accessibility labels
Button(action: startExploring) {
    Image("icon")
}
```

### Testing with Accessibility Features

Before submitting PR:
1. Enable **VoiceOver** on test device
2. Navigate entire UI with VoiceOver only
3. Test **Large Text** (Settings > Accessibility > Larger Accessibility Sizes)
4. Test **High Contrast** mode
5. Verify **button sizes** are at least 44x44 points

---

## 🤖 ML Model Improvements

### Contributing Detection Models

If improving object detection or hazard recognition:

1. **Document your training data**
   - What dataset did you use?
   - How many samples?
   - What augmentations?

2. **Benchmark accuracy**
   - Provide mAP scores
   - Compare to baseline
   - Test on diverse scenarios

3. **Optimize for mobile**
   - Measure inference time
   - Check model size
   - Test memory usage
   - Verify FPS on target devices

4. **Validate with users**
   - Test with blind/low-vision users
   - Gather feedback
   - Document improvements

### Example Model PR

```
Title: Improve hazard detection accuracy for stairs

Description:
- Retrained HazardDetector with 5000+ stair images
- Added varied lighting conditions and angles
- Improved mAP from 0.82 to 0.89

Benchmarks:
- Inference time: 18ms → 20ms (acceptable)
- Model size: 6.8 MB → 6.9 MB
- FPS maintained: 40-80 FPS

Testing:
- Tested on 10+ real homes with blind testers
- 95% accuracy in detecting stairs
- Zero false negatives (safety critical)
```

---

## 📝 Commit Messages

Write clear, descriptive commit messages:

```
# ✅ Good format:
Add priority-based hazard detection interruption

- Hazard alerts now interrupt other announcements
- Reduces latency for critical warnings
- Adds visual indicator when hazard detected

Fixes #123

# ❌ Bad:
fixed stuff
bug fix
update

# ❌ Too vague:
Changes to detection

# ✅ Specific:
Improve YOLOv8 inference latency on iPhone 12

- Optimize memory allocation during frame processing
- Reduce buffer copies from 3 to 1
- Latency reduced from 80ms to 50ms
```

---

## 🧪 Testing Requirements

### Unit Tests (if applicable)
```swift
// Test detection accuracy
func testYOLOv8Detection() {
    let result = detector.detect(in: testFrame)
    XCTAssertEqual(result.count, expectedCount)
    XCTAssertGreater(result[0].confidence, 0.8)
}
```

### Integration Testing
- Test with real camera feeds
- Test all ML models
- Verify speech output
- Check memory usage under load

### Accessibility Testing
- Enable VoiceOver and navigate UI
- Test with Large Text enabled
- Verify High Contrast colors
- Test with real blind/low-vision users if possible

---

## 🔄 PR Review Process

1. **Automated Checks**
   - Code builds without errors
   - Swift style checked
   - No breaking changes to API

2. **Manual Review**
   - Code quality and architecture
   - Accessibility compliance
   - Performance impact
   - Documentation updates

3. **Testing**
   - Reviewer tests on device
   - Verifies accessibility
   - Checks edge cases

4. **Merge**
   - Squash commits if needed
   - Merge to main branch
   - Close associated issues

---

## 📚 Development Resources

### Apple Frameworks
- [Vision Framework](https://developer.apple.com/documentation/vision)
- [CoreML Guide](https://developer.apple.com/machine-learning/core-ml/)
- [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- [Combine](https://developer.apple.com/documentation/combine)
- [AVFoundation](https://developer.apple.com/av-foundation/)

### Accessibility
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Apple Accessibility Guide](https://www.apple.com/accessibility/)
- [WebAIM Color Contrast](https://webaim.org/articles/contrast/)

### ML & Computer Vision
- [YOLOv8 Documentation](https://docs.ultralytics.com/)
- [COCO Dataset](https://cocodataset.org/)
- [Create ML Guide](https://developer.apple.com/machine-learning/create-ml/)

---

## ❓ Questions?

- 📧 **Email**: hallieimran@gmail.com
- 💬 **Discussions**: [GitHub Discussions](https://github.com/yourusername/EchoVision/discussions)
- 🐛 **Issues**: [GitHub Issues](https://github.com/yourusername/EchoVision/issues)

---

## 🙏 Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors, regardless of:
- Age
- Body size
- Disability
- Ethnicity
- Gender identity
- Level of experience
- Nationality
- Personal appearance
- Race
- Religion
- Sexual identity
- Sexual orientation

### Expected Behavior

- Use welcoming and inclusive language
- Be respectful of differing opinions
- Accept constructive criticism gracefully
- Focus on what is best for the community
- Show empathy towards other community members

### Unacceptable Behavior

- Harassment of any kind
- Discriminatory language or jokes
- Unwelcome sexual attention or advances
- Trolling, insulting/derogatory comments
- Public or private attacks

---

## 📄 License

By contributing to EchoVision, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for making EchoVision better! 🌟**

Together, we're building technology that empowers and includes everyone.
