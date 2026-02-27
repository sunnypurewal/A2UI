import Foundation

public struct TextProperties: Codable, Sendable {
    public let text: BoundValue<String>
    public let variant: A2UITextVariant? // h1, h2, h3, h4, h5, caption, body
    
    public init(text: BoundValue<String>, variant: A2UITextVariant?) {
        self.text = text
        self.variant = variant
    }
    
    enum CodingKeys: String, CodingKey {
        case text, variant
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(BoundValue<String>.self, forKey: .text)
        self.variant = try container.decodeIfPresent(A2UITextVariant.self, forKey: .variant)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(variant, forKey: .variant)
    }
}

public enum A2UITextVariant: String, Codable, Sendable {
	case h1 = "h1"
	case h2 = "h2"
	case h3 = "h3"
	case h4 = "h4"
	case h5 = "h5"
	case caption = "caption"
	case body = "body"
}
