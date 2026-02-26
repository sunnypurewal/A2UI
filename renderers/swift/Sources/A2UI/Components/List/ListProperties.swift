import Foundation

public struct ListProperties: Codable, Sendable {
    public let children: Children
    public let direction: String? // vertical, horizontal
    public let align: String?
}
