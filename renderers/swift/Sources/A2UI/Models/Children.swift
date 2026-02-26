import Foundation

public enum Children: Codable, Sendable {
    case list([String])
    case template(Template)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let list = try? container.decode([String].self) {
            self = .list(list)
        } else if let template = try? container.decode(Template.self) {
            self = .template(template)
        } else {
            // Support legacy v0.8 explicitList wrapper for compatibility
            let keyedContainer = try decoder.container(keyedBy: RawCodingKey.self)
            if let explicitList = try? keyedContainer.decode([String].self, forKey: RawCodingKey(stringValue: "explicitList")!) {
                self = .list(explicitList)
            } else if let template = try? keyedContainer.decode(Template.self, forKey: RawCodingKey(stringValue: "template")!) {
                self = .template(template)
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Children must be an array of strings, a template object, or a legacy explicitList/template wrapper.")
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .list(let list):
            try container.encode(list)
        case .template(let template):
            try container.encode(template)
        }
    }
}

public struct Template: Codable, Sendable {
    public let componentId: String
    public let path: String
}
