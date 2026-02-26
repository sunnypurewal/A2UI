import Foundation

public struct JSONNull: Codable, Sendable, Hashable {
    public init() {}
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() { throw DecodingError.typeMismatch(JSONNull.self, .init(codingPath: decoder.codingPath, debugDescription: "")) }
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer(); try container.encodeNil()
    }
}

public struct AnyCodable: Codable, Sendable {
    public let value: Sendable
    public init(_ value: Sendable) { self.value = value }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() { value = JSONNull() }
        else if let x = try? container.decode(String.self) { value = x }
        else if let x = try? container.decode(Bool.self) { value = x }
        else if let x = try? container.decode(Double.self) { value = x }
        else if let x = try? container.decode([String: AnyCodable].self) { value = x.mapValues { $0.value } }
        else if let x = try? container.decode([AnyCodable].self) { value = x.map { $0.value } }
        else { throw DecodingError.dataCorruptedError(in: container, debugDescription: "Wrong type") }
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if value is JSONNull { try container.encodeNil() }
        else if let x = value as? String { try container.encode(x) }
        else if let x = value as? Bool { try container.encode(x) }
        else if let x = value as? Double { try container.encode(x) }
        else if let x = value as? [String: Sendable] { try container.encode(x.mapValues { AnyCodable($0) }) }
        else if let x = value as? [Sendable] { try container.encode(x.map { AnyCodable($0) }) }
    }
}
