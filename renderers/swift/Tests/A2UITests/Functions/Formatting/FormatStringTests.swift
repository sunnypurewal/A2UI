import Foundation
import Testing
@testable import A2UI

@MainActor
struct FormatStringTests {
    private let surface = SurfaceState(id: "test")

    @Test func formatString() async {
        surface.setValue(at: "/user/name", value: "Alice")
        let call = FunctionCall.formatString(value: "Hello, ${/user/name}!")
        #expect(A2UIStandardFunctions.evaluate(call: call, surface: surface) as? String == "Hello, Alice!")
    }

    @Test func formatStringEdgeCases() async {
        let call1 = FunctionCall.formatString(value: "Value is ${/does/not/exist} or ${direct_expr}")
        let result1 = A2UIStandardFunctions.evaluate(call: call1, surface: surface) as? String
        #expect(result1 == "Value is  or ${direct_expr}")
        
		let invalid = FunctionCall.formatString(value: 123)
        #expect(A2UIStandardFunctions.evaluate(call: invalid, surface: surface) as? String == "")
    }
}
