import Foundation
import Testing
@testable import A2UI

@MainActor
struct FormatCurrencyTests {
    private let surface = SurfaceState(id: "test")

    @Test func formatCurrency() throws {
        let call = FunctionCall.formatCurrency(value: 1234.56, currency: "USD")
		let result: String! = A2UIStandardFunctions.evaluate(call: call, surface: surface) as? String
		try #require(result != nil)
        #expect(result.contains("$"))
		#expect(result.contains("234"))
		#expect(result.contains("56"))
    }

    @Test func formatCurrencyEdgeCases() throws {
        let call = FunctionCall.formatCurrency(value: 1234.56, currency: "GBP", decimals: 0, grouping: false)
		let result: String! = A2UIStandardFunctions.evaluate(call: call, surface: surface) as? String
		try #require(result != nil)
		#expect(result.contains("1235"))
		#expect(result.contains("£"))
		#expect(!result.contains("$"))
        
        let invalid = FunctionCall(call: "formatCurrency", args: ["value": AnyCodable("not-double")])
        #expect(A2UIStandardFunctions.evaluate(call: invalid, surface: surface) as? String == "")
    }
}
