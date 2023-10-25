import Foundation
import CoreML
import Yams

public struct InputMetadata {
    public private(set) var size: CGSize
}

public struct OutputMetadata {
    public private(set) var classes: Dictionary<Int, String>
    public private(set) var keypoints: Int
    public private(set) var dimensions: Int
}

public struct PoseModelMetadata {
    public private(set) var input: InputMetadata
    public private(set) var output: OutputMetadata
    
    init(for model: MLModel) {
        let description = model.modelDescription
        let input = description.inputDescriptionsByName

        let inputFeatureDescription = input.first?.value
        let imageConstraint = inputFeatureDescription!.imageConstraint!
        
        let userDefinedObject = description.metadata[MLModelMetadataKey.creatorDefinedKey] as? Dictionary<String, String>
        
        guard let kptShape = userDefinedObject?["kpt_shape"] else { fatalError() }
        guard let names = userDefinedObject?["names"] else { fatalError() }
        
        let jsonDecoder = JSONDecoder()
        let yamlDecoder = YAMLDecoder()

        let metadata = try! jsonDecoder.decode(Array<Int>.self, from: kptShape.data(using: .utf8)!)
        let classNames = try! yamlDecoder.decode(Dictionary<Int, String>.self, from: names.data(using: .utf8)!)
        
        self.input = InputMetadata(
            size: CGSize(
                width: imageConstraint.pixelsWide,
                height: imageConstraint.pixelsHigh
            )
        )
        
        self.output = OutputMetadata(
            classes: classNames,
            keypoints: metadata[0],
            dimensions: metadata[1]
        )
    }
}

