import Foundation

import Testing
@testable import A2UI

@MainActor
struct A2UIFunctionTests {
    private let surface = SurfaceState(id: "test")

    @Test func required() async {
        var call = FunctionCall.required(value: "hello")
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == true)

        call = FunctionCall.required(value: "")
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == false)
        
        call = FunctionCall.required(value: JSONNull())
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == false)
    }

    @Test func regex() async {
        var call = FunctionCall.regex(value: "123", pattern: "^[0-9]+$")
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == true)

        call = FunctionCall.regex(value: "abc", pattern: "^[0-9]+$")
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == false)
    }

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

    @Test func numeric() async {
        var call = FunctionCall.numeric(value: 10.0, min: 5.0, max: 15.0)
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == true)
		
		call = FunctionCall.numeric(value: 20.0, min: 5.0, max: 15.0)
		#expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == false)

		call = FunctionCall.numeric(value: 20.0, max: 15.0)
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == false)
		
		call = FunctionCall.numeric(value: 10.0, max: 15.0)
		#expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == true)
        
		call = FunctionCall.numeric(value: 10, min: 5.0)
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == true)
		
		call = FunctionCall.numeric(value: 1, min: 5.0)
		#expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == false)

        // Missing both min and max should fail according to anyOf spec
		call = FunctionCall.numeric(value: 10.0)
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == false)
    }

    @Test func email() async {
        var call = FunctionCall.email(value: "test@example.com")
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == true)

        call = FunctionCall.email(value: "invalid-email")
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == false)
    }

    @Test func formatString() async {
        surface.setValue(at: "/user/name", value: "Alice")
        let call = FunctionCall.formatString(value: "Hello, ${/user/name}!")
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? String == "Hello, Alice!")
    }

    @Test func formatNumber() async {
        let call = FunctionCall.formatNumber(value: 1234.567, decimals: 2.0, grouping: true)
        let result = A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? String
        // Locale dependent, but should contain 1,234.57 or 1.234,57
        #expect(result?.contains("1") ?? false)
        #expect(result?.contains("234") ?? false)
        #expect(result?.contains("57") ?? false)
    }

    @Test func formatCurrency() async {
        let call = FunctionCall.formatCurrency(value: 1234.56, currency: "USD")
        let result = A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? String
        #expect(result?.contains("$") ?? false)
        let containsCorrectFormat = result?.contains("1,234.56") ?? false || result?.contains("1.234,56") ?? false
        #expect(containsCorrectFormat)
    }

    @Test func formatDate() async {
        // Use a fixed timestamp for testing: 2026-02-26T12:00:00Z (roughly)
        let timestamp = 1772107200.0 // Thu Feb 26 2026 12:00:00 UTC
        let call = FunctionCall.formatDate(value: timestamp, format: "yyyy-MM-dd")
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? String == "2026-02-26")
    }

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

    @Test func logical() async {
        var call = FunctionCall.and(values: [true, true])
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == true)

        call = FunctionCall.and(values: [true, false])
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == false)

        // Min 2 items check
        call = FunctionCall.and(values: [true])
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == false)

        call = FunctionCall.or(values: [true, false])
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == true)

        call = FunctionCall.not(value: true)
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == false)
    }
    
    @Test func nestedFunctionCall() async {
        // not(isRequired(value: "")) -> not(false) -> true
        let innerCall: [String: Sendable] = [
            "call": "required",
            "args": ["value": ""]
        ]
        let outerCall = FunctionCall.not(value: innerCall)
        #expect(A2UIFunctionEvaluator.evaluate(call: outerCall, surface: surface) as? Bool == true)
    }
    
    @Test func dataBindingInFunctionCall() async {
        surface.setValue(at: "/test/val", value: "hello")
        let binding: [String: Sendable] = ["path": "/test/val"]
        let call = FunctionCall.required(value: binding)
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == true)
    }

    @Test func arrayResolutionInFunctionCall() async {
        surface.setValue(at: "/test/bool1", value: true)
        surface.setValue(at: "/test/bool2", value: false)
        
        let binding1: [String: Sendable] = ["path": "/test/bool1"]
        let binding2: [String: Sendable] = ["path": "/test/bool2"]
        
        let call = FunctionCall.and(values: [binding1, binding2])
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == false)
        
        surface.setValue(at: "/test/bool2", value: true)
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == true)
    }

    @Test func checkableLogic() async {
        surface.setValue(at: "/email", value: "invalid")
        let condition = BoundValue<Bool>(functionCall: FunctionCall.email(value: ["path": "/email"]))
        let check = CheckRule(condition: condition, message: "Invalid email")
        
        let error = errorMessage(surface: surface, checks: [check])
        #expect(error == "Invalid email")
        
        surface.setValue(at: "/email", value: "test@example.com")
        let noError = errorMessage(surface: surface, checks: [check])
        #expect(noError == nil)
    }
    // MARK: - New tests to increase coverage

    @Test func openUrl() async {
        let badCall = FunctionCall(call: "openUrl", args: ["url": AnyCodable("")])
        #expect(A2UIFunctionEvaluator.evaluate(call: badCall, surface: surface) == nil)
        
        let invalidArgs = FunctionCall(call: "openUrl", args: ["url": AnyCodable(123)])
        #expect(A2UIFunctionEvaluator.evaluate(call: invalidArgs, surface: surface) == nil)
    }

    @Test func formatDateEdgeCases() async {
        let date = Date(timeIntervalSince1970: 0)
        let call1 = FunctionCall.formatDate(value: date, format: "yyyy")
        let res1 = A2UIFunctionEvaluator.evaluate(call: call1, surface: surface) as? String
        #expect(res1 == "1970" || res1 == "1969")

        let call2 = FunctionCall.formatDate(value: "1970-01-01T00:00:00Z", format: "yyyy")
        let res2 = A2UIFunctionEvaluator.evaluate(call: call2, surface: surface) as? String
        #expect(res2 == "1970" || res2 == "1969")

        let call3 = FunctionCall.formatDate(value: "bad-date", format: "yyyy")
        #expect(A2UIFunctionEvaluator.evaluate(call: call3, surface: surface) as? String == "bad-date")

        let call4 = FunctionCall(call: "formatDate", args: [
            "value": AnyCodable(["a", "b"] as [Sendable]),
            "format": AnyCodable("yyyy")
        ])
        let result4 = A2UIFunctionEvaluator.evaluate(call: call4, surface: surface) as? String
        #expect(result4 != nil)
    }

    @Test func formatCurrencyEdgeCases() async {
        let call1 = FunctionCall.formatCurrency(value: 1234.56, currency: "USD", decimals: 0, grouping: false)
        let result1 = A2UIFunctionEvaluator.evaluate(call: call1, surface: surface) as? String
        #expect(result1?.contains("1235") == true || result1?.contains("1234") == true)
        
        let invalid = FunctionCall(call: "formatCurrency", args: ["value": AnyCodable("not-double")])
        #expect(A2UIFunctionEvaluator.evaluate(call: invalid, surface: surface) as? String == "")
    }

    @Test func formatNumberEdgeCases() async {
        let call1 = FunctionCall.formatNumber(value: 1234.56, decimals: nil, grouping: false)
        let result1 = A2UIFunctionEvaluator.evaluate(call: call1, surface: surface) as? String
        #expect(result1?.contains("1234.56") == true || result1?.contains("1234,56") == true)
        
        let invalid = FunctionCall(call: "formatNumber", args: ["value": AnyCodable("not-double")])
        #expect(A2UIFunctionEvaluator.evaluate(call: invalid, surface: surface) as? String == "")

        let callGrouping = FunctionCall(call: "formatNumber", args: [
            "value": AnyCodable(1234.56)
        ])
        let resGrouping = A2UIFunctionEvaluator.evaluate(call: callGrouping, surface: surface) as? String
        #expect(resGrouping?.contains("1") == true)
    }

    @Test func formatStringEdgeCases() async {
        let call1 = FunctionCall.formatString(value: "Value is ${/does/not/exist} or ${direct_expr}")
        let result1 = A2UIFunctionEvaluator.evaluate(call: call1, surface: surface) as? String
        #expect(result1 == "Value is  or ${direct_expr}")
        
        let invalid = FunctionCall(call: "formatString", args: ["value": AnyCodable(123)])
        #expect(A2UIFunctionEvaluator.evaluate(call: invalid, surface: surface) as? String == "")
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

    @Test func regexEdgeCases() async {
        let call1 = FunctionCall.regex(value: "test", pattern: "[a-z") // Invalid regex
        #expect(A2UIFunctionEvaluator.evaluate(call: call1, surface: surface) as? Bool == false)
        
        let invalid1 = FunctionCall(call: "regex", args: ["value": AnyCodable("test")])
        #expect(A2UIFunctionEvaluator.evaluate(call: invalid1, surface: surface) as? Bool == false)
    }

    @Test func missingOrInvalidFunctionsAndArguments() async {
        let unknown = FunctionCall(call: "someRandomFunction")
        #expect(A2UIFunctionEvaluator.evaluate(call: unknown, surface: surface) == nil)
        
        let reqInvalid = FunctionCall(call: "required")
        #expect(A2UIFunctionEvaluator.evaluate(call: reqInvalid, surface: surface) as? Bool == false)
        
        let emailInvalid = FunctionCall(call: "email", args: ["value": AnyCodable(123)])
        #expect(A2UIFunctionEvaluator.evaluate(call: emailInvalid, surface: surface) as? Bool == false)
        
        let lenInvalid1 = FunctionCall(call: "length", args: ["value": AnyCodable(123), "min": AnyCodable(1)])
        #expect(A2UIFunctionEvaluator.evaluate(call: lenInvalid1, surface: surface) as? Bool == false)

        let numInvalid = FunctionCall(call: "numeric", args: ["value": AnyCodable(123)])
        #expect(A2UIFunctionEvaluator.evaluate(call: numInvalid, surface: surface) as? Bool == false)

        let andInvalid = FunctionCall(call: "and", args: ["values": AnyCodable(123)])
        #expect(A2UIFunctionEvaluator.evaluate(call: andInvalid, surface: surface) as? Bool == false)
        
        let orInvalid = FunctionCall(call: "or", args: ["values": AnyCodable([true] as [Sendable])])
        #expect(A2UIFunctionEvaluator.evaluate(call: orInvalid, surface: surface) as? Bool == false)
        
        let notInvalid = FunctionCall(call: "not", args: ["value": AnyCodable(123)])
        #expect(A2UIFunctionEvaluator.evaluate(call: notInvalid, surface: surface) as? Bool == false)
    }

    @Test func resolveDynamicValueEdgeCases() async {
        let arrVal: [Sendable] = [["path": "/test/val"] as [String: Sendable]]
        surface.setValue(at: "/test/val", value: "resolved")
        
        let result = A2UIFunctionEvaluator.resolveDynamicValue(arrVal, surface: surface) as? [Any]
        #expect(result?.first as? String == "resolved")
        
        let nullRes = A2UIFunctionEvaluator.resolveDynamicValue(NSNull(), surface: surface) as? NSNull
        #expect(nullRes != nil)
    }
}

private extension FunctionCall {
    static func required(value: Sendable?) -> FunctionCall {
        FunctionCall(call: "required", args: ["value": AnyCodable(value)])
    }

    static func regex(value: Sendable, pattern: Sendable) -> FunctionCall {
        FunctionCall(call: "regex", args: ["value": AnyCodable(value), "pattern": AnyCodable(pattern)])
    }

    static func length(value: Sendable, min: Sendable? = nil, max: Sendable? = nil) -> FunctionCall {
        var args: [String: AnyCodable] = ["value": AnyCodable(value)]
        if let min { args["min"] = AnyCodable(min) }
        if let max { args["max"] = AnyCodable(max) }
        return FunctionCall(call: "length", args: args)
    }

    static func numeric(value: Sendable, min: Sendable? = nil, max: Sendable? = nil) -> FunctionCall {
        var args: [String: AnyCodable] = ["value": AnyCodable(value)]
        if let min { args["min"] = AnyCodable(min) }
        if let max { args["max"] = AnyCodable(max) }
        return FunctionCall(call: "numeric", args: args)
    }

    static func email(value: Sendable) -> FunctionCall {
        FunctionCall(call: "email", args: ["value": AnyCodable(value)])
    }

    static func formatString(value: Sendable) -> FunctionCall {
        FunctionCall(call: "formatString", args: ["value": AnyCodable(value)])
    }

    static func formatNumber(value: Sendable, decimals: Sendable? = nil, grouping: Sendable? = nil) -> FunctionCall {
        var args: [String: AnyCodable] = ["value": AnyCodable(value)]
        if let decimals { args["decimals"] = AnyCodable(decimals) }
        if let grouping { args["grouping"] = AnyCodable(grouping) }
        return FunctionCall(call: "formatNumber", args: args)
    }

    static func formatCurrency(value: Sendable, currency: Sendable) -> FunctionCall {
        FunctionCall(call: "formatCurrency", args: ["value": AnyCodable(value), "currency": AnyCodable(currency)])
    }

    static func formatDate(value: Sendable, format: Sendable) -> FunctionCall {
        FunctionCall(call: "formatDate", args: ["value": AnyCodable(value), "format": AnyCodable(format)])
    }

    static func pluralize(value: Sendable, zero: Sendable? = nil, one: Sendable? = nil, two: Sendable? = nil, other: Sendable) -> FunctionCall {
        var args: [String: AnyCodable] = ["value": AnyCodable(value), "other": AnyCodable(other)]
        if let zero { args["zero"] = AnyCodable(zero) }
        if let one { args["one"] = AnyCodable(one) }
        if let two { args["two"] = AnyCodable(two) }
        return FunctionCall(call: "pluralize", args: args)
    }

    static func and(values: Sendable) -> FunctionCall {
        FunctionCall(call: "and", args: ["values": AnyCodable(values)])
    }

    static func or(values: Sendable) -> FunctionCall {
        FunctionCall(call: "or", args: ["values": AnyCodable(values)])
    }

    static func not(value: Sendable) -> FunctionCall {
        FunctionCall(call: "not", args: ["value": AnyCodable(value)])
    }
    static func formatCurrency(value: Sendable, currency: Sendable, decimals: Int, grouping: Bool) -> FunctionCall {
        FunctionCall(call: "formatCurrency", args: [
            "value": AnyCodable(value),
            "currency": AnyCodable(currency),
            "decimals": AnyCodable(decimals),
            "grouping": AnyCodable(grouping)
        ])
    }
}
