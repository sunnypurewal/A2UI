import Foundation

public struct ChoicePickerProperties: Codable, Sendable {
    public let label: BoundValue<String>?
    public let options: [SelectionOption]
    public let variant: ChoicePickerVariant?
    public let value: BoundValue<[String]>
    public let checks: [CheckRule]?

    public init(label: BoundValue<String>? = nil, options: [SelectionOption], variant: ChoicePickerVariant? = nil, value: BoundValue<[String]>, checks: [CheckRule]? = nil) {
        self.label = label
        self.options = options
        self.variant = variant
        self.value = value
        self.checks = checks
    }
}

public struct SelectionOption: Codable, Sendable {
    public let label: BoundValue<String>
    public let value: String
}

public enum ChoicePickerVariant: String, Codable, Sendable, CaseIterable, Identifiable {
	public var id: String { self.rawValue }
	case multipleSelection = "multipleSelection"
	case mutuallyExclusive = "mutuallyExclusive"
}
