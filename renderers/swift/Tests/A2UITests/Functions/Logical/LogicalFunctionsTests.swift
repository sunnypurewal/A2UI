import Foundation
import Testing
@testable import A2UI

@MainActor
struct LogicalFunctionsTests {
    private let surface = SurfaceState(id: "test")

    @Test func logical() async {
        var call = FunctionCall.and(values: [true, true])
        #expect(A2UIStandardFunctions.evaluate(call: call, surface: surface) as? Bool == true)

        call = FunctionCall.and(values: [true, false])
        #expect(A2UIStandardFunctions.evaluate(call: call, surface: surface) as? Bool == false)

        // Min 2 items check
        call = FunctionCall.and(values: [true])
        #expect(A2UIStandardFunctions.evaluate(call: call, surface: surface) as? Bool == false)

        call = FunctionCall.or(values: [true, false])
        #expect(A2UIStandardFunctions.evaluate(call: call, surface: surface) as? Bool == true)

        call = FunctionCall.not(value: true)
        #expect(A2UIStandardFunctions.evaluate(call: call, surface: surface) as? Bool == false)
    }
}
