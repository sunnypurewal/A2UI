import Foundation

public struct CheckBoxProperties: Codable, Sendable {
    public let label: BoundValue<String>
    public let value: BoundValue<Bool>
}
