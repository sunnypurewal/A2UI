import Testing
@testable import A2UI
import Foundation

struct FunctionCallTests {
    @Test func functionCallCodable() throws {
        let json = """
        {
            "call": "formatDate",
            "args": {"timestamp": 12345},
            "returnType": "String"
        }
        """.data(using: .utf8)!

        let call = try JSONDecoder().decode(FunctionCall.self, from: json)
        #expect(call.call == "formatDate")
        #expect(call.returnType == "String")
        #expect(call.args["timestamp"] == AnyCodable(12345.0))

        let encoded = try JSONEncoder().encode(call)
        let decoded = try JSONDecoder().decode(FunctionCall.self, from: encoded)
        #expect(call == decoded)
        
        let emptyCall = FunctionCall(call: "empty")
        let emptyEncoded = try JSONEncoder().encode(emptyCall)
        let emptyDecoded = try JSONDecoder().decode(FunctionCall.self, from: emptyEncoded)
        #expect(emptyCall == emptyDecoded)
    }
}
