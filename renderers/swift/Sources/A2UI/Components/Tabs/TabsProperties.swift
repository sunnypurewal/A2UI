import Foundation

public struct TabsProperties: Codable, Sendable {
    public let tabs: [TabItem]
}

public struct TabItem: Codable, Sendable {
    public let title: BoundValue<String>
    public let child: String
}
