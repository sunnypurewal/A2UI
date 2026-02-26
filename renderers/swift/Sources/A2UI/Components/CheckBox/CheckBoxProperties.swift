import Foundation

public struct CheckBoxProperties: Codable, Sendable {
    public let label: BoundValue<String>
    public let value: BoundValue<Bool>

    public init(label: BoundValue<String>, value: BoundValue<Bool>) {
        self.label = label
        self.value = value
    }
}
