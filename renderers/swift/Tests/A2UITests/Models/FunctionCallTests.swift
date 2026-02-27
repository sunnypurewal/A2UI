import XCTest
@testable import A2UI

final class FunctionCallTests: XCTestCase {
    func testFunctionCallCodable() throws {
        let json = """
        {
            "call": "formatDate",
            "args": {"timestamp": 12345},
            "returnType": "String"
        }
        """.data(using: .utf8)!

        let call = try JSONDecoder().decode(FunctionCall.self, from: json)
        XCTAssertEqual(call.call, "formatDate")
        XCTAssertEqual(call.returnType, "String")
        XCTAssertEqual(call.args["timestamp"], AnyCodable(12345.0))

        let encoded = try JSONEncoder().encode(call)
        let decoded = try JSONDecoder().decode(FunctionCall.self, from: encoded)
        XCTAssertEqual(call, decoded)
        
        let emptyCall = FunctionCall(call: "empty")
        let emptyEncoded = try JSONEncoder().encode(emptyCall)
        let emptyDecoded = try JSONDecoder().decode(FunctionCall.self, from: emptyEncoded)
        XCTAssertEqual(emptyCall, emptyDecoded)
    }
}
