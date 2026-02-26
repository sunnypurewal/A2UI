import Foundation

public struct BoundValue<T: Codable & Sendable & Equatable>: Codable, Sendable, Equatable {
    public let literal: T?
    public let path: String?

    enum CodingKeys: String, CodingKey {
        case path
    }

    public init(literal: T? = nil, path: String? = nil) {
        self.literal = literal
        self.path = path
    }

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(), let val = try? container.decode(T.self) {
            self.literal = val
            self.path = nil
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.path = try container.decodeIfPresent(String.self, forKey: .path)
            self.literal = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let path = path {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(path, forKey: .path)
        } else if let literal = literal {
            var container = encoder.singleValueContainer()
            try container.encode(literal)
        }
    }
}
