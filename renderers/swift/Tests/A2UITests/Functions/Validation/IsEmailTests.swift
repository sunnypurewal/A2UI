import Foundation
import Testing
@testable import A2UI

@MainActor
struct IsEmailTests {
    private let surface = SurfaceState(id: "test")

    @Test func email() async {
        var call = FunctionCall.email(value: "test@example.com")
        #expect(A2UIStandardFunctions.evaluate(call: call, surface: surface) as? Bool == true)

        call = FunctionCall.email(value: "invalid-email")
        #expect(A2UIStandardFunctions.evaluate(call: call, surface: surface) as? Bool == false)
    }
}
