import Foundation

public struct ButtonProperties: Codable, Sendable {
    public let child: String
    public let action: Action
    public let variant: ButtonVariant?
    public let checks: [CheckRule]?

    public init(child: String, action: Action, variant: ButtonVariant? = nil, checks: [CheckRule]? = nil) {
        self.child = child
        self.action = action
        self.variant = variant
        self.checks = checks
    }
}

public enum ButtonVariant: String, Codable, Sendable, CaseIterable, Identifiable {
	public var id: String { self.rawValue }
	case primary
	case borderless
}
