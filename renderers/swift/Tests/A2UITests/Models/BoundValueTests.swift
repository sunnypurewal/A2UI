import Testing
@testable import A2UI
import Foundation

struct BoundValueTests {
    @Test func boundValueDecodeEncode() throws {
        // Literal Int -> gets decoded as Double via literal fallback
        let literalJson = "42".data(using: .utf8)!
        let literalVal = try JSONDecoder().decode(BoundValue<Double>.self, from: literalJson)
        #expect(literalVal.literal == 42.0)
        #expect(literalVal.path == nil)
        
        // Path
        let pathJson = #"{"path": "user.age"}"#.data(using: .utf8)!
        let pathVal = try JSONDecoder().decode(BoundValue<Double>.self, from: pathJson)
        #expect(pathVal.path == "user.age")
        #expect(pathVal.literal == nil)
        #expect(pathVal.functionCall == nil)
        
        // Function Call
        let funcJson = #"{"call": "getAge"}"#.data(using: .utf8)!
        let funcVal = try JSONDecoder().decode(BoundValue<Double>.self, from: funcJson)
        #expect(funcVal.functionCall != nil)
        #expect(funcVal.functionCall?.call == "getAge")
        
        // Encode
        let encodedLiteral = try JSONEncoder().encode(literalVal)
        let decodedLiteral = try JSONDecoder().decode(BoundValue<Double>.self, from: encodedLiteral)
        #expect(decodedLiteral.literal == 42.0)
        
        let encodedPath = try JSONEncoder().encode(pathVal)
        let decodedPath = try JSONDecoder().decode(BoundValue<Double>.self, from: encodedPath)
        #expect(decodedPath.path == "user.age")
        
        let encodedFunc = try JSONEncoder().encode(funcVal)
        let decodedFunc = try JSONDecoder().decode(BoundValue<Double>.self, from: encodedFunc)
        #expect(decodedFunc.functionCall?.call == "getAge")
    }
}
