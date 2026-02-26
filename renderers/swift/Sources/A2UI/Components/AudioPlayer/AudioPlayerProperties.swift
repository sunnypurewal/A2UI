import Foundation

public struct AudioPlayerProperties: Codable, Sendable {
    public let url: BoundValue<String>
    public let description: BoundValue<String>?
}
