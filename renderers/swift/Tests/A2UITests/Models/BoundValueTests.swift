import XCTest
@testable import A2UI

final class BoundValueTests: XCTestCase {
    func testBoundValueDecodeEncode() throws {
        // Literal Int -> gets decoded as Double via literal fallback
        let literalJson = "42".data(using: .utf8)!
        let literalVal = try JSONDecoder().decode(BoundValue<Double>.self, from: literalJson)
        XCTAssertEqual(literalVal.literal, 42.0)
        XCTAssertNil(literalVal.path)
        
        // Path
        let pathJson = #"{"path": "user.age"}"#.data(using: .utf8)!
        let pathVal = try JSONDecoder().decode(BoundValue<Double>.self, from: pathJson)
        XCTAssertEqual(pathVal.path, "user.age")
        XCTAssertNil(pathVal.literal)
        XCTAssertNil(pathVal.functionCall)
        
        // Function Call
        let funcJson = #"{"call": "getAge"}"#.data(using: .utf8)!
        let funcVal = try JSONDecoder().decode(BoundValue<Double>.self, from: funcJson)
        XCTAssertNotNil(funcVal.functionCall)
        XCTAssertEqual(funcVal.functionCall?.call, "getAge")
        
        // Encode
        let encodedLiteral = try JSONEncoder().encode(literalVal)
        let decodedLiteral = try JSONDecoder().decode(BoundValue<Double>.self, from: encodedLiteral)
        XCTAssertEqual(decodedLiteral.literal, 42.0)
        
        let encodedPath = try JSONEncoder().encode(pathVal)
        let decodedPath = try JSONDecoder().decode(BoundValue<Double>.self, from: encodedPath)
        XCTAssertEqual(decodedPath.path, "user.age")
        
        let encodedFunc = try JSONEncoder().encode(funcVal)
        let decodedFunc = try JSONDecoder().decode(BoundValue<Double>.self, from: encodedFunc)
        XCTAssertEqual(decodedFunc.functionCall?.call, "getAge")
    }
}
