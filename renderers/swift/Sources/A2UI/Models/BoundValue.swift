import Foundation

public struct BoundValue<T: Codable & Sendable & Equatable>: Codable, Sendable, Equatable {
    public let literal: T?
    public let path: String?
    public let functionCall: FunctionCall?

    enum CodingKeys: String, CodingKey {
        case path
        case call
        case args
        case returnType
        case functionCall
    }

    public init(literal: T? = nil, path: String? = nil, functionCall: FunctionCall? = nil) {
        self.literal = literal
        self.path = path
        self.functionCall = functionCall
    }

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(), let val = try? container.decode(T.self) {
            self.literal = val
            self.path = nil
            self.functionCall = nil
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.path = try container.decodeIfPresent(String.self, forKey: .path)
            
            if container.contains(.call) {
                // Direct function call properties
                self.functionCall = try FunctionCall(from: decoder)
            } else if container.contains(.functionCall) {
                // Wrapped in "functionCall" object
                self.functionCall = try container.decode(FunctionCall.self, forKey: .functionCall)
            } else {
                self.functionCall = nil
            }
            
            self.literal = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let functionCall = functionCall {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(functionCall, forKey: .functionCall)
        } else if let path = path {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(path, forKey: .path)
        } else if let literal = literal {
            var container = encoder.singleValueContainer()
            try container.encode(literal)
        }
    }
}
