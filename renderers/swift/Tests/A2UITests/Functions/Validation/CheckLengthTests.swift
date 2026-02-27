import Foundation
import Testing
@testable import A2UI

@MainActor
struct CheckLengthTests {
    private let surface = SurfaceState(id: "test")

    @Test func length() async {
        var call = FunctionCall.length(value: "test", min: 2.0, max: 5.0)
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == true)

        call = FunctionCall.length(value: "t", min: 2.0)
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == false)

		call = FunctionCall.length(value: "testtest", max: 5.0)
		#expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == false)
		
        // Missing both min and max should fail according to anyOf spec
        call = FunctionCall.length(value: "test")
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == false)
    }
}
