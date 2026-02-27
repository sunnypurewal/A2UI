import Foundation

/// Represents a user-initiated action sent from the client to the server.
/// Matches the 'action' property in the A2UI v0.9 client-to-server schema.
public struct UserAction: Codable, Sendable {
    public let name: String
    public let surfaceId: String
    public let sourceComponentId: String
    public let timestamp: Date
    public let context: [String: AnyCodable]

    public init(name: String, surfaceId: String, sourceComponentId: String, timestamp: Date = Date(), context: [String: AnyCodable] = [:]) {
        self.name = name
        self.surfaceId = surfaceId
        self.sourceComponentId = sourceComponentId
        self.timestamp = timestamp
        self.context = context
    }
}
