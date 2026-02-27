import Foundation

public struct ImageProperties: Codable, Sendable {
    public let url: BoundValue<String>
    public let fit: A2UIImageFit? // contain, cover, fill, none, scaleDown
    public let variant: A2UIImageVariant? // icon, avatar, smallFeature, mediumFeature, largeFeature, header
}

public enum A2UIImageVariant: String, Codable, Sendable {
	case icon = "icon"
	case avatar = "avatar"
	case smallFeature = "smallFeature"
	case mediumFeature = "mediumFeature"
	case largeFeature = "largeFeature"
	case header = "header"
}

public enum A2UIImageFit: String, Codable, Sendable {
	case contain = "contain"
	case cover = "cover"
	case fill = "fill"
	case none = "none"
	case scaleDown = "scaleDown"
}
