import Foundation

public struct PosePrediction {
    var `class`: String
    var confidence: Float
    var box: CGRect
    var points: Array<(x: Float, y: Float)>
}
