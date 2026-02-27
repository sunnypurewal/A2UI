import Foundation

public struct ContainerProperties: Codable, Sendable {
    public let children: Children
    public let justify: A2UIJustify?
    public let align: A2UIAlign?

    enum CodingKeys: String, CodingKey {
        case children, justify, align
    }
}

extension ContainerProperties {
    public var resolvedJustify: A2UIJustify {
		justify ?? .spaceBetween
    }

    public var resolvedAlign: A2UIAlign {
        align ?? .center
    }
}

public enum A2UIJustify: String, Codable, Sendable {
    case center = "center"
    case end = "end"
    case spaceAround = "spaceAround"
    case spaceBetween = "spaceBetween"
    case spaceEvenly = "spaceEvenly"
    case start = "start"
    case stretch = "stretch"
}

public enum A2UIAlign: String, Codable, Sendable {
	case start = "start"
	case center = "center"
	case end = "end"
	case stretch = "stretch"
}
