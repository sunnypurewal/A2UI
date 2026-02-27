import Foundation

public struct DividerProperties: Codable, Sendable {
    public let axis: DividerAxis?
}

public enum DividerAxis: String, Codable, Sendable, CaseIterable, Identifiable {
    public var id: String { self.rawValue }
	case horizontal
	case vertical
}
