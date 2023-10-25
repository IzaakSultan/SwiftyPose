# SwiftyPose

A YOLOV8 pose model parser

## Installation
### Swift Package Manager
Installing SwiftyPose is as easy as adding it to the `dependencies` property of your `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/IzaakSultan/SwiftyPose.git", from "0.0.4")
]
```

## Usage

```swift
let pose = SwiftyPose(model: YourYOLOV8PoseModel().model)

func processDetections(for request: VNRequest, error: Error?) {
    guard error == nil else {
        print("Object detection error: \(error!.localizedDescription)")
        return
    }

    guard let results = request.results else { return }

    for observation in results where observation is VNCoreMLFeatureValueObservation {
        guard let observation = observation as? VNCoreMLFeatureValueObservation else { continue }
        
        let results = pose.parse(observation: observation)
    }
}
```
