import Foundation
import Testing
@testable import A2UI

@MainActor
struct MatchesRegexTests {
    private let surface = SurfaceState(id: "test")

    @Test func regex() async {
        var call = FunctionCall.regex(value: "123", pattern: "^[0-9]+$")
        #expect(A2UIStandardFunctions.evaluate(call: call, surface: surface) as? Bool == true)

        call = FunctionCall.regex(value: "abc", pattern: "^[0-9]+$")
        #expect(A2UIStandardFunctions.evaluate(call: call, surface: surface) as? Bool == false)
    }

    @Test func regexEdgeCases() async {
        let call1 = FunctionCall.regex(value: "test", pattern: "[a-z") // Invalid regex
        #expect(A2UIStandardFunctions.evaluate(call: call1, surface: surface) as? Bool == false)
        
        let invalid1 = FunctionCall(call: "regex", args: ["value": AnyCodable("test")])
        #expect(A2UIStandardFunctions.evaluate(call: invalid1, surface: surface) as? Bool == false)
    }
}
