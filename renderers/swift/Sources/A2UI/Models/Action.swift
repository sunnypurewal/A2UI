import Foundation

public enum Action: Codable, Sendable {
    case custom(name: String, context: [String: AnyCodable]?)
    case dataUpdate(DataUpdateAction)
    case functionCall(FunctionCall)

    enum CodingKeys: String, CodingKey {
        case name, context, dataUpdate, functionCall, event
    }

    struct EventPayload: Decodable {
        let name: String
        let context: [String: AnyCodable]?
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let dataUpdate = try? container.decode(DataUpdateAction.self, forKey: .dataUpdate) {
            self = .dataUpdate(dataUpdate)
        } else if let functionCall = try? container.decode(FunctionCall.self, forKey: .functionCall) {
            self = .functionCall(functionCall)
        } else if let event = try? container.decode(EventPayload.self, forKey: .event) {
            self = .custom(name: event.name, context: event.context)
        } else if let name = try? container.decode(String.self, forKey: .name) {
            let context = try? container.decode([String: AnyCodable].self, forKey: .context)
            self = .custom(name: name, context: context)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .name, in: container, debugDescription: "Unknown Action type")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .custom(let name, let context):
            try container.encode(name, forKey: .name)
            try container.encodeIfPresent(context, forKey: .context)
        case .dataUpdate(let du): try container.encode(du, forKey: .dataUpdate)
        case .functionCall(let fc): try container.encode(fc, forKey: .functionCall)
        }
    }
}

public struct DataUpdateAction: Codable, Sendable {
    public let path: String
    public let contents: AnyCodable // Can be a value or expression
}
