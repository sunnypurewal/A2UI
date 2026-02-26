import Foundation

public struct SliderProperties: Codable, Sendable {
    public let label: BoundValue<String>?
    public let min: Double
    public let max: Double
    public let value: BoundValue<Double>
}
