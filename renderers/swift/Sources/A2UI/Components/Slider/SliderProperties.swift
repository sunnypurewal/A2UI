import Foundation

public struct SliderProperties: Codable, Sendable {
    public let label: BoundValue<String>?
    public let min: Double
    public let max: Double
    public let value: BoundValue<Double>
    public let checks: [CheckRule]?

    public init(label: BoundValue<String>? = nil, min: Double, max: Double, value: BoundValue<Double>, checks: [CheckRule]? = nil) {
        self.label = label
        self.min = min
        self.max = max
        self.value = value
        self.checks = checks
    }
}
