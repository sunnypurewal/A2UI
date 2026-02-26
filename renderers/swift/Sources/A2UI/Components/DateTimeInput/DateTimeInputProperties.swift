import Foundation

public struct DateTimeInputProperties: Codable, Sendable {
    public let label: BoundValue<String>?
    public let value: BoundValue<String>
    public let enableDate: Bool?
    public let enableTime: Bool?
    public let min: BoundValue<String>?
    public let max: BoundValue<String>?
    public let checks: [CheckRule]?
}
