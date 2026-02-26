import Foundation

public struct DateTimeInputProperties: Codable, Sendable {
    public let label: BoundValue<String>?
    public let value: BoundValue<String>
    public let enableDate: Bool?
    public let enableTime: Bool?
    public let min: BoundValue<String>?
    public let max: BoundValue<String>?

    public init(label: BoundValue<String>? = nil, value: BoundValue<String>, enableDate: Bool? = nil, enableTime: Bool? = nil, min: BoundValue<String>? = nil, max: BoundValue<String>? = nil) {
        self.label = label
        self.value = value
        self.enableDate = enableDate
        self.enableTime = enableTime
        self.min = min
        self.max = max
    }
}
