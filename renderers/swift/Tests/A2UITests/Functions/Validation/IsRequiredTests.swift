import Foundation
import Testing
@testable import A2UI

@MainActor
struct IsRequiredTests {
    private let surface = SurfaceState(id: "test")

    @Test func required() async {
        var call = FunctionCall.required(value: "hello")
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == true)

        call = FunctionCall.required(value: "")
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == false)
        
        call = FunctionCall.required(value: JSONNull())
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == false)
    }
}
