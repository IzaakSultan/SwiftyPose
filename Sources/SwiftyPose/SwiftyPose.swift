import Foundation
import Vision
import CoreML

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

public class SwiftyPose {
    private(set) var model: MLModel
    private(set) var metadata: PoseModelMetadata

    public init(model: MLModel) {
        self.model = model
        self.metadata = PoseModelMetadata(for: model)
    }
    
    public func parse(observation: VNCoreMLFeatureValueObservation, threshold: Float = 0.6) -> Array<PosePrediction> {
        let shapedArray = observation.featureValue.shapedArrayValue(of: Float.self)!

        let dimensions = shapedArray.shape[1]
        let predictions = shapedArray.shape[2]
        
        let classesNum = dimensions - 4 - metadata.output.keypoints * metadata.output.dimensions
        let inputWidth = Float(metadata.input.size.width)

        return nonMaxSupression((0..<predictions).compactMap { index in
            let prediction = shapedArray[0...0, 0..<shapedArray.shape[1], index...index].scalars
            let confidences = Array(prediction[4..<(4+classesNum)])
            
            if confidences.contains(where: { $0 > threshold }) {
                let width = prediction[2]
                let height = prediction[3]
                
                let x = prediction[0] - width / 2
                let y = prediction[1] - height / 2

                let points = Array(prediction[4+classesNum..<dimensions]).chunked(into: metadata.output.dimensions).map { (x: $0[0], y: $0[1]) }
                let confidence = confidences.enumerated().max(by: { $0.element < $1.element })!
                
                return PosePrediction(
                    class: metadata.output.classes[confidence.offset] ?? "",
                    confidence: confidence.element,
                    box: CGRect(
                        x: Double(x / inputWidth),
                        y: Double(y / inputWidth),
                        width: Double(width / inputWidth),
                        height: 1.0 - Double(y / inputWidth)
                    ),
                    points: points
                )
            }
            
            return nil
        })
    }
    
    private func nonMaxSupression(_ predictions: Array<PosePrediction>, threshold: Double = 0.5) -> Array<PosePrediction> {
        if (predictions.count < 2) { return predictions }

        let sorted = predictions.sorted { $0.confidence > $1.confidence }
        var keep = Array(repeating: true, count: sorted.count)
        var keepPredictions: Array<PosePrediction> = []
        
        for i in 0..<sorted.count {
            if (keep[i]) {
                let prediction = sorted[i]

                keepPredictions.append(prediction)
                
                let bbox1 = prediction.box
                
                for j in (i + 1)..<sorted.count {
                    if (keep[j]) {
                        let predictionJ = sorted[j]
                        let bbox2 = predictionJ.box
                        
                        if (intersectionOverUnion(bbox1, bbox2) > threshold) {
                            keep[j] = false
                        }
                    }
                }
            }
        }
        
        return sorted.enumerated().filter { keep[$0.offset] }.map { $0.element }
    }
    
    private func intersectionOverUnion(_ rect1: CGRect, _ rect2: CGRect) -> Double {
        let intersection = CGRectIntersection(rect1, rect2)
        let union = CGRectUnion(rect1, rect2)
        
        if CGRectIsNull(intersection) {
            return 0
        }
        
        return (intersection.size.width * intersection.size.height) / (union.size.width * union.size.height)
    }
}
