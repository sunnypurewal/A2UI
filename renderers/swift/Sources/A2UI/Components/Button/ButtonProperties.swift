import Foundation

public struct ButtonProperties: Codable, Sendable {
    public let child: String
    public let action: Action
    public let variant: String? // primary, borderless
}
