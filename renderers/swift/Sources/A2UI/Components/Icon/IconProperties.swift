import Foundation

public struct IconProperties: Codable, Sendable {
    public let name: BoundValue<String> // v0.10: String or path object, we'll keep it simple for now
}
