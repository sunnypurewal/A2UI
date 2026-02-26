import Foundation

public struct CheckBoxProperties: Codable, Sendable {
    public let label: BoundValue<String>
    public let value: BoundValue<Bool>
    public let checks: [CheckRule]?

    public init(label: BoundValue<String>, value: BoundValue<Bool>, checks: [CheckRule]? = nil) {
        self.label = label
        self.value = value
        self.checks = checks
    }
}
