import Foundation

public enum Action: Codable, Sendable {
    case event(name: String, context: [String: AnyCodable]?)
    case functionCall(FunctionCall)

    enum CodingKeys: String, CodingKey {
        case event, functionCall
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let eventPayload = try? container.decode(EventPayload.self, forKey: .event) {
            self = .event(name: eventPayload.name, context: eventPayload.context)
        } else if let functionCall = try? container.decode(FunctionCall.self, forKey: .functionCall) {
            self = .functionCall(functionCall)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown Action type or missing v0.10 structure (event or functionCall)")
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .event(let name, let context):
            try container.encode(EventPayload(name: name, context: context), forKey: .event)
        case .functionCall(let fc):
            try container.encode(fc, forKey: .functionCall)
        }
    }
}

public struct EventPayload: Codable, Sendable {
    public let name: String
    public let context: [String: AnyCodable]?

    public init(name: String, context: [String: AnyCodable]? = nil) {
        self.name = name
        self.context = context
    }
}

public struct DataUpdateAction: Sendable {
    public let path: String
    public let contents: AnyCodable
    
    public init(path: String, contents: AnyCodable) {
        self.path = path
        self.contents = contents
    }
}
