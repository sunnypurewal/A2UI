import Foundation
import Testing
@testable import A2UI

@MainActor
struct PluralizeTests {
    private let surface = SurfaceState(id: "test")

    @Test func pluralize() async {
        var call = FunctionCall.pluralize(value: 1.0, one: "item", other: "items")
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? String == "item")

        call = FunctionCall.pluralize(value: 2.0, one: "item", other: "items")
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? String == "items")

        // Test with optional categories
        call = FunctionCall.pluralize(value: 0.0, zero: "none", other: "some")
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? String == "none")

        call = FunctionCall.pluralize(value: 2.0, two: "couple", other: "many")
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? String == "couple")
    }

    @Test func pluralizeEdgeCases() async {
        let call1 = FunctionCall(call: "pluralize", args: ["value": AnyCodable(1), "other": AnyCodable("others")])
        #expect(A2UIFunctionEvaluator.evaluate(call: call1, surface: surface) as? String == "others")
        
        let call2 = FunctionCall(call: "pluralize", args: ["value": AnyCodable(0), "other": AnyCodable("others")])
        #expect(A2UIFunctionEvaluator.evaluate(call: call2, surface: surface) as? String == "others")

        let call3 = FunctionCall(call: "pluralize", args: ["value": AnyCodable(2), "other": AnyCodable("others")])
        #expect(A2UIFunctionEvaluator.evaluate(call: call3, surface: surface) as? String == "others")
        
        let invalid = FunctionCall(call: "pluralize", args: ["value": AnyCodable("not-double")])
        #expect(A2UIFunctionEvaluator.evaluate(call: invalid, surface: surface) as? String == "")

        let callOtherNum = FunctionCall.pluralize(value: 5, other: "others")
        let resOtherNum = A2UIFunctionEvaluator.evaluate(call: callOtherNum, surface: surface) as? String
        #expect(resOtherNum == "others")
    }
}
