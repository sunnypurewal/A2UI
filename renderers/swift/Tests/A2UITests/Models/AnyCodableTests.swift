import XCTest
@testable import A2UI

final class AnyCodableTests: XCTestCase {
    func testAnyCodableJSONNull() throws {
        let json = "null".data(using: .utf8)!
        let val = try JSONDecoder().decode(AnyCodable.self, from: json)
        XCTAssertTrue(val.value is JSONNull)
        XCTAssertEqual(val, AnyCodable(JSONNull()))
        
        let encoded = try JSONEncoder().encode(val)
        XCTAssertEqual(String(data: encoded, encoding: .utf8), "null")
    }

    func testAnyCodableTypes() throws {
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
        XCTAssertEqual(dict["string"], AnyCodable("test"))
        XCTAssertEqual(dict["bool"], AnyCodable(true))
        XCTAssertEqual(dict["double"], AnyCodable(1.5))
        
        let encoded = try JSONEncoder().encode(dict)
        let decodedDict = try JSONDecoder().decode([String: AnyCodable].self, from: encoded)
        
        XCTAssertEqual(dict["string"], decodedDict["string"])
        XCTAssertEqual(dict["bool"], decodedDict["bool"])
        XCTAssertEqual(dict["double"], decodedDict["double"])
        
        XCTAssertEqual(AnyCodable([1.0, "two"] as [Sendable]), AnyCodable([1.0, "two"] as [Sendable]))
    }
    
    func testAnyCodableDataCorrupted() throws {
        let invalidJson = #"{"test": "#.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(AnyCodable.self, from: invalidJson))
    }

    func testAnyCodableEquality() {
        XCTAssertEqual(AnyCodable(JSONNull()), AnyCodable(JSONNull()))
        XCTAssertEqual(AnyCodable("a"), AnyCodable("a"))
        XCTAssertNotEqual(AnyCodable("a"), AnyCodable("b"))
        XCTAssertEqual(AnyCodable(true), AnyCodable(true))
        XCTAssertEqual(AnyCodable(1.0), AnyCodable(1.0))
        
        let dict1: [String: Sendable] = ["a": 1.0]
        let dict2: [String: Sendable] = ["a": 1.0]
        XCTAssertEqual(AnyCodable(dict1), AnyCodable(dict2))
        
        let arr1: [Sendable] = [1.0, 2.0]
        let arr2: [Sendable] = [1.0, 2.0]
        XCTAssertEqual(AnyCodable(arr1), AnyCodable(arr2))
        
        XCTAssertNotEqual(AnyCodable("string"), AnyCodable(1.0))
    }

    func testAnyCodableArrayEncode() throws {
        let arr: [Sendable] = ["hello", 1.0, true]
        let val = AnyCodable(arr)
        let encoded = try JSONEncoder().encode(val)
        let decoded = try JSONDecoder().decode(AnyCodable.self, from: encoded)
        XCTAssertEqual(val, decoded)
    }

    func testJSONNull() throws {
        let nullVal = JSONNull()
        let encoded = try JSONEncoder().encode(nullVal)
        let decoded = try JSONDecoder().decode(JSONNull.self, from: encoded)
        XCTAssertEqual(nullVal, decoded)
        
        let invalid = "123".data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(JSONNull.self, from: invalid))
    }
}
