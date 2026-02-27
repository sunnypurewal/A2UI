import Foundation
import Testing
@testable import A2UI

@MainActor
struct FormatNumberTests {
    private let surface = SurfaceState(id: "test")

    @Test func formatNumber() async {
        let call = FunctionCall.formatNumber(value: 1234.567, decimals: 2.0, grouping: true)
        let result = A2UIStandardFunctions.evaluate(call: call, surface: surface) as? String
        // Locale dependent, but should contain 1,234.57 or 1.234,57
        #expect(result?.contains("1") ?? false)
        #expect(result?.contains("234") ?? false)
        #expect(result?.contains("57") ?? false)
    }

    @Test func formatNumberEdgeCases() async {
        let call1 = FunctionCall.formatNumber(value: 1234.56, decimals: nil, grouping: false)
        let result1 = A2UIStandardFunctions.evaluate(call: call1, surface: surface) as? String
        #expect(result1?.contains("1234.56") == true || result1?.contains("1234,56") == true)
        
        let invalid = FunctionCall(call: "formatNumber", args: ["value": AnyCodable("not-double")])
        #expect(A2UIStandardFunctions.evaluate(call: invalid, surface: surface) as? String == "")

        let callGrouping = FunctionCall(call: "formatNumber", args: [
            "value": AnyCodable(1234.56)
        ])
        let resGrouping = A2UIStandardFunctions.evaluate(call: callGrouping, surface: surface) as? String
        #expect(resGrouping?.contains("1") == true)
    }
}
