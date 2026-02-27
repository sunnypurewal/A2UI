import Foundation
import Testing
@testable import A2UI

@MainActor
struct FormatCurrencyTests {
    private let surface = SurfaceState(id: "test")

    @Test func formatCurrency() async {
        let call = FunctionCall.formatCurrency(value: 1234.56, currency: "USD")
        let result = A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? String
        #expect(result?.contains("$") ?? false)
        let containsCorrectFormat = result?.contains("1,234.56") ?? false || result?.contains("1.234,56") ?? false
        #expect(containsCorrectFormat)
    }

    @Test func formatCurrencyEdgeCases() async {
        let call1 = FunctionCall.formatCurrency(value: 1234.56, currency: "USD", decimals: 0, grouping: false)
        let result1 = A2UIFunctionEvaluator.evaluate(call: call1, surface: surface) as? String
        #expect(result1?.contains("1235") == true || result1?.contains("1234") == true)
        
        let invalid = FunctionCall(call: "formatCurrency", args: ["value": AnyCodable("not-double")])
        #expect(A2UIFunctionEvaluator.evaluate(call: invalid, surface: surface) as? String == "")
    }
}
