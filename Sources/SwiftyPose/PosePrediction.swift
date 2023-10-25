import Foundation

public struct PosePrediction {
    public private(set) var `class`: String
    public private(set) var confidence: Float
    public private(set) var box: CGRect
    public private(set) var points: Array<(x: Float, y: Float)>
}
