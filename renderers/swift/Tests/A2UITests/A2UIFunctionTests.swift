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
}
