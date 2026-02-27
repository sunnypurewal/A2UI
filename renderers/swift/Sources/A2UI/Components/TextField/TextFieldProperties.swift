import Foundation

public struct TextFieldProperties: Codable, Sendable {
    public let label: BoundValue<String>
    public let value: BoundValue<String>?
    public let variant: TextFieldVariant? // longText, number, shortText, obscured

    public init(label: BoundValue<String>, value: BoundValue<String>? = nil, variant: TextFieldVariant? = nil) {
        self.label = label
        self.value = value
        self.variant = variant
    }
}

public enum TextFieldVariant: String, Codable, Sendable, CaseIterable, Identifiable {
    public var id: String { self.rawValue }
	case longText = "longText"
	case number = "number"
	case shortText = "shortText"
	case obscured = "obscured"
}
