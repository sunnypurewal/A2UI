import Foundation

public struct FunctionCall: Codable, Sendable, Equatable {
    public let call: String
    public let args: [String: AnyCodable]
    public let returnType: String?

    enum CodingKeys: String, CodingKey {
        case call, args, returnType
    }

    public init(call: String, args: [String: AnyCodable] = [:], returnType: String? = nil) {
        self.call = call
        self.args = args
        self.returnType = returnType
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        call = try container.decode(String.self, forKey: .call)
        args = try container.decodeIfPresent([String: AnyCodable].self, forKey: .args) ?? [:]
        returnType = try container.decodeIfPresent(String.self, forKey: .returnType)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(call, forKey: .call)
        if !args.isEmpty {
            try container.encode(args, forKey: .args)
        }
        try container.encodeIfPresent(returnType, forKey: .returnType)
    }

    public static func == (lhs: FunctionCall, rhs: FunctionCall) -> Bool {
        return lhs.call == rhs.call && lhs.args == rhs.args && lhs.returnType == rhs.returnType
    }
}
