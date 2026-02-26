import Foundation

public struct TextFieldProperties: Codable, Sendable {
    public let label: BoundValue<String>
    public let value: BoundValue<String>?
    public let variant: String? // longText, number, shortText, obscured
}
