import Foundation

public struct ButtonProperties: Codable, Sendable {
    public let child: String
    public let action: Action
    public let variant: ButtonVariant?
}

public enum ButtonVariant: String, Codable, Sendable, CaseIterable, Identifiable {
	public var id: String { self.rawValue }
	case primary
	case borderless
}
