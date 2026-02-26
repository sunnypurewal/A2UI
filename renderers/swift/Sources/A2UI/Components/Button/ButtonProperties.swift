import Foundation

public struct ButtonProperties: Codable, Sendable {
    public let child: String
    public let action: Action
    public let variant: ButtonVariant?

    public init(child: String, action: Action, variant: ButtonVariant? = nil) {
        self.child = child
        self.action = action
        self.variant = variant
    }
}

public enum ButtonVariant: String, Codable, Sendable, CaseIterable, Identifiable {
	public var id: String { self.rawValue }
	case primary
	case borderless
}
