import Testing
@testable import A2UI

@MainActor
struct A2UIFunctionTests {
    private let surface = SurfaceState(id: "test")

    @Test func required() async {
        let call = FunctionCall(call: "required", args: ["value": AnyCodable("hello")])
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == true)

        let call2 = FunctionCall(call: "required", args: ["value": AnyCodable("")])
        #expect(A2UIFunctionEvaluator.evaluate(call: call2, surface: surface) as? Bool == false)
        
        let call3 = FunctionCall(call: "required", args: ["value": AnyCodable(JSONNull())])
        #expect(A2UIFunctionEvaluator.evaluate(call: call3, surface: surface) as? Bool == false)
    }

    @Test func regex() async {
        let call = FunctionCall(call: "regex", args: ["value": AnyCodable("123"), "pattern": AnyCodable("^[0-9]+$")])
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == true)

        let call2 = FunctionCall(call: "regex", args: ["value": AnyCodable("abc"), "pattern": AnyCodable("^[0-9]+$")])
        #expect(A2UIFunctionEvaluator.evaluate(call: call2, surface: surface) as? Bool == false)
    }

    @Test func length() async {
        let call = FunctionCall(call: "length", args: ["value": AnyCodable("test"), "min": AnyCodable(2.0), "max": AnyCodable(5.0)])
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == true)

        let call2 = FunctionCall(call: "length", args: ["value": AnyCodable("t"), "min": AnyCodable(2.0)])
        #expect(A2UIFunctionEvaluator.evaluate(call: call2, surface: surface) as? Bool == false)

		
		let call3 = FunctionCall(call: "length", args: ["value": AnyCodable("testtest"), "max": AnyCodable(5.0)])
		#expect(A2UIFunctionEvaluator.evaluate(call: call3, surface: surface) as? Bool == false)
		
        // Missing both min and max should fail according to anyOf spec
        let call4 = FunctionCall(call: "length", args: ["value": AnyCodable("test")])
        #expect(A2UIFunctionEvaluator.evaluate(call: call4, surface: surface) as? Bool == false)
    }

    @Test func numeric() async {
        var call = FunctionCall(call: "numeric", args: ["value": AnyCodable(10.0), "min": AnyCodable(5.0), "max": AnyCodable(15.0)])
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == true)

		call = FunctionCall(call: "numeric", args: ["value": AnyCodable(20.0), "max": AnyCodable(15.0)])
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == false)
        
		call = FunctionCall(call: "numeric", args: ["value": AnyCodable("10"), "min": AnyCodable(5.0)])
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == true)
		
		call = FunctionCall(call: "numeric", args: ["value": AnyCodable("1"), "min": AnyCodable(5.0)])
		#expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == true)

        // Missing both min and max should fail according to anyOf spec
		call = FunctionCall(call: "numeric", args: ["value": AnyCodable(10.0)])
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == false)
    }

    @Test func email() async {
        let call = FunctionCall(call: "email", args: ["value": AnyCodable("test@example.com")])
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == true)

        let call2 = FunctionCall(call: "email", args: ["value": AnyCodable("invalid-email")])
        #expect(A2UIFunctionEvaluator.evaluate(call: call2, surface: surface) as? Bool == false)
    }

    @Test func formatString() async {
        surface.setValue(at: "/user/name", value: "Alice")
        let call = FunctionCall(call: "formatString", args: ["value": AnyCodable("Hello, ${/user/name}!")])
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? String == "Hello, Alice!")
    }

    @Test func formatNumber() async {
        let call = FunctionCall(call: "formatNumber", args: ["value": AnyCodable(1234.567), "decimals": AnyCodable(2.0), "grouping": AnyCodable(true)])
        let result = A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? String
        // Locale dependent, but should contain 1,234.57 or 1.234,57
        #expect(result?.contains("1") ?? false)
        #expect(result?.contains("234") ?? false)
        #expect(result?.contains("57") ?? false)
    }

    @Test func formatCurrency() async {
        let call = FunctionCall(call: "formatCurrency", args: ["value": AnyCodable(1234.56), "currency": AnyCodable("USD")])
        let result = A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? String
        #expect(result?.contains("$") ?? false)
        let containsCorrectFormat = result?.contains("1,234.56") ?? false || result?.contains("1.234,56") ?? false
        #expect(containsCorrectFormat)
    }

    @Test func formatDate() async {
        // Use a fixed timestamp for testing: 2026-02-26T12:00:00Z (roughly)
        let timestamp = 1772107200.0 // Thu Feb 26 2026 12:00:00 UTC
        let call = FunctionCall(call: "formatDate", args: ["value": AnyCodable(timestamp), "format": AnyCodable("yyyy-MM-dd")])
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? String == "2026-02-26")
    }

    @Test func pluralize() async {
        let args: [String: AnyCodable] = [
            "value": AnyCodable(1.0),
            "one": AnyCodable("item"),
            "other": AnyCodable("items")
        ]
        let call = FunctionCall(call: "pluralize", args: args)
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? String == "item")

        let args2: [String: AnyCodable] = [
            "value": AnyCodable(2.0),
            "one": AnyCodable("item"),
            "other": AnyCodable("items")
        ]
        let call2 = FunctionCall(call: "pluralize", args: args2)
        #expect(A2UIFunctionEvaluator.evaluate(call: call2, surface: surface) as? String == "items")

        // Test with optional categories
        let args3: [String: AnyCodable] = [
            "value": AnyCodable(0.0),
            "zero": AnyCodable("none"),
            "other": AnyCodable("some")
        ]
        let call3 = FunctionCall(call: "pluralize", args: args3)
        #expect(A2UIFunctionEvaluator.evaluate(call: call3, surface: surface) as? String == "none")

        let args4: [String: AnyCodable] = [
            "value": AnyCodable(2.0),
            "two": AnyCodable("couple"),
            "other": AnyCodable("many")
        ]
        let call4 = FunctionCall(call: "pluralize", args: args4)
        #expect(A2UIFunctionEvaluator.evaluate(call: call4, surface: surface) as? String == "couple")
    }

    @Test func logical() async {
        let andCall = FunctionCall(call: "and", args: ["values": AnyCodable([true, true])])
        #expect(A2UIFunctionEvaluator.evaluate(call: andCall, surface: surface) as? Bool == true)

        let andCall2 = FunctionCall(call: "and", args: ["values": AnyCodable([true, false])])
        #expect(A2UIFunctionEvaluator.evaluate(call: andCall2, surface: surface) as? Bool == false)

        // Min 2 items check
        let andCall3 = FunctionCall(call: "and", args: ["values": AnyCodable([true])])
        #expect(A2UIFunctionEvaluator.evaluate(call: andCall3, surface: surface) as? Bool == false)

        let orCall = FunctionCall(call: "or", args: ["values": AnyCodable([true, false])])
        #expect(A2UIFunctionEvaluator.evaluate(call: orCall, surface: surface) as? Bool == true)

        let notCall = FunctionCall(call: "not", args: ["value": AnyCodable(true)])
        #expect(A2UIFunctionEvaluator.evaluate(call: notCall, surface: surface) as? Bool == false)
    }
    
    @Test func nestedFunctionCall() async {
        // not(isRequired(value: "")) -> not(false) -> true
        let innerCall: [String: Sendable] = [
            "call": "required",
            "args": ["value": ""]
        ]
        let outerCall = FunctionCall(call: "not", args: ["value": AnyCodable(innerCall)])
        #expect(A2UIFunctionEvaluator.evaluate(call: outerCall, surface: surface) as? Bool == true)
    }
    
    @Test func dataBindingInFunctionCall() async {
        surface.setValue(at: "/test/val", value: "hello")
        let binding: [String: Sendable] = ["path": "/test/val"]
        let call = FunctionCall(call: "required", args: ["value": AnyCodable(binding)])
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == true)
    }

    @Test func arrayResolutionInFunctionCall() async {
        surface.setValue(at: "/test/bool1", value: true)
        surface.setValue(at: "/test/bool2", value: false)
        
        let binding1: [String: Sendable] = ["path": "/test/bool1"]
        let binding2: [String: Sendable] = ["path": "/test/bool2"]
        
        let call = FunctionCall(call: "and", args: ["values": AnyCodable([binding1, binding2])])
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == false)
        
        surface.setValue(at: "/test/bool2", value: true)
        #expect(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool == true)
    }

    @Test func checkableLogic() async {
        surface.setValue(at: "/email", value: "invalid")
        let condition = BoundValue<Bool>(functionCall: FunctionCall(call: "email", args: ["value": AnyCodable(["path": "/email"])]))
        let check = CheckRule(condition: condition, message: "Invalid email")
        
        let error = errorMessage(surface: surface, checks: [check])
        #expect(error == "Invalid email")
        
        surface.setValue(at: "/email", value: "test@example.com")
        let noError = errorMessage(surface: surface, checks: [check])
        #expect(noError == nil)
    }
}
