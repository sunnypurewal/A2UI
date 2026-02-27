import Foundation

public struct DividerProperties: Codable, Sendable {
    public let axis: DividerAxis?
}

public enum DividerAxis: String, Codable, Sendable {
	case horizontal
	case vertical
}
