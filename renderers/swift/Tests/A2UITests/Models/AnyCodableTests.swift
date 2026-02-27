import Testing
@testable import A2UI
import Foundation

struct AnyCodableTests {
    @Test func anyCodableJSONNull() throws {
        let json = "null".data(using: .utf8)!
        let val = try JSONDecoder().decode(AnyCodable.self, from: json)
        #expect(val.value is JSONNull)
        #expect(val == AnyCodable(JSONNull()))
        
        let encoded = try JSONEncoder().encode(val)
        #expect(String(data: encoded, encoding: .utf8) == "null")
    }

    @Test func anyCodableTypes() throws {
        let json = """
        {
            "string": "test",
            "bool": true,
            "double": 1.5,
            "array": [1.0, "two"],
            "dict": {"key": "value"}
        }
        """.data(using: .utf8)!

        let dict = try JSONDecoder().decode([String: AnyCodable].self, from: json)
        #expect(dict["string"] == AnyCodable("test"))
        #expect(dict["bool"] == AnyCodable(true))
        #expect(dict["double"] == AnyCodable(1.5))
        
        let encoded = try JSONEncoder().encode(dict)
        let decodedDict = try JSONDecoder().decode([String: AnyCodable].self, from: encoded)
        
        #expect(dict["string"] == decodedDict["string"])
        #expect(dict["bool"] == decodedDict["bool"])
        #expect(dict["double"] == decodedDict["double"])
        
        #expect(AnyCodable([1.0, "two"] as [Sendable]) == AnyCodable([1.0, "two"] as [Sendable]))
    }
    
    @Test func anyCodableDataCorrupted() throws {
        let invalidJson = #"{"test": "#.data(using: .utf8)!
        #expect(throws: Error.self) { try JSONDecoder().decode(AnyCodable.self, from: invalidJson) }
    }

    @Test func anyCodableEquality() {
        #expect(AnyCodable(JSONNull()) == AnyCodable(JSONNull()))
        #expect(AnyCodable("a") == AnyCodable("a"))
        #expect(AnyCodable("a") != AnyCodable("b"))
        #expect(AnyCodable(true) == AnyCodable(true))
        #expect(AnyCodable(1.0) == AnyCodable(1.0))
        
        let dict1: [String: Sendable] = ["a": 1.0]
        let dict2: [String: Sendable] = ["a": 1.0]
        #expect(AnyCodable(dict1) == AnyCodable(dict2))
        
        let arr1: [Sendable] = [1.0, 2.0]
        let arr2: [Sendable] = [1.0, 2.0]
        #expect(AnyCodable(arr1) == AnyCodable(arr2))
        
        #expect(AnyCodable("string") != AnyCodable(1.0))
    }

    @Test func anyCodableArrayEncode() throws {
        let arr: [Sendable] = ["hello", 1.0, true]
        let val = AnyCodable(arr)
        let encoded = try JSONEncoder().encode(val)
        let decoded = try JSONDecoder().decode(AnyCodable.self, from: encoded)
        #expect(val == decoded)
    }

    @Test func jsonNull() throws {
        let nullVal = JSONNull()
        let encoded = try JSONEncoder().encode(nullVal)
        let decoded = try JSONDecoder().decode(JSONNull.self, from: encoded)
        #expect(nullVal == decoded)
        
        let invalid = "123".data(using: .utf8)!
        #expect(throws: Error.self) { try JSONDecoder().decode(JSONNull.self, from: invalid) }
    }
}
