import Foundation
import Testing
@testable import A2UI

@MainActor
struct CheckNumericTests {
    private let surface = SurfaceState(id: "test")

    @Test func numeric() async {
        var call = FunctionCall.numeric(value: 10.0, min: 5.0, max: 15.0)
        #expect(A2UIStandardFunctions.evaluate(call: call, surface: surface) as? Bool == true)
		
		call = FunctionCall.numeric(value: 20.0, min: 5.0, max: 15.0)
		#expect(A2UIStandardFunctions.evaluate(call: call, surface: surface) as? Bool == false)

		call = FunctionCall.numeric(value: 20.0, max: 15.0)
        #expect(A2UIStandardFunctions.evaluate(call: call, surface: surface) as? Bool == false)
		
		call = FunctionCall.numeric(value: 10.0, max: 15.0)
		#expect(A2UIStandardFunctions.evaluate(call: call, surface: surface) as? Bool == true)
        
		call = FunctionCall.numeric(value: 10, min: 5.0)
        #expect(A2UIStandardFunctions.evaluate(call: call, surface: surface) as? Bool == true)
		
		call = FunctionCall.numeric(value: 1, min: 5.0)
		#expect(A2UIStandardFunctions.evaluate(call: call, surface: surface) as? Bool == false)

        // Missing both min and max should fail according to anyOf spec
		call = FunctionCall.numeric(value: 10.0)
        #expect(A2UIStandardFunctions.evaluate(call: call, surface: surface) as? Bool == false)
    }
}
