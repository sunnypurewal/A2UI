import XCTest
@testable import A2UI

@MainActor
final class A2UIFunctionTests: XCTestCase {
    var surface: SurfaceState!

    override func setUp() async throws {
        try await super.setUp()
        surface = SurfaceState(id: "test")
    }

    func testRequired() async {
        let call = FunctionCall(call: "required", args: ["value": AnyCodable("hello")])
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool, true)

        let call2 = FunctionCall(call: "required", args: ["value": AnyCodable("")])
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: call2, surface: surface) as? Bool, false)
        
        let call3 = FunctionCall(call: "required", args: ["value": AnyCodable(JSONNull())])
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: call3, surface: surface) as? Bool, false)
    }

    func testRegex() async {
        let call = FunctionCall(call: "regex", args: ["value": AnyCodable("123"), "pattern": AnyCodable("^[0-9]+$")])
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool, true)

        let call2 = FunctionCall(call: "regex", args: ["value": AnyCodable("abc"), "pattern": AnyCodable("^[0-9]+$")])
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: call2, surface: surface) as? Bool, false)
    }

    func testLength() async {
        let call = FunctionCall(call: "length", args: ["value": AnyCodable("test"), "min": AnyCodable(2.0), "max": AnyCodable(5.0)])
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool, true)

        let call2 = FunctionCall(call: "length", args: ["value": AnyCodable("t"), "min": AnyCodable(2.0)])
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: call2, surface: surface) as? Bool, false)
    }

    func testNumeric() async {
        let call = FunctionCall(call: "numeric", args: ["value": AnyCodable(10.0), "min": AnyCodable(5.0), "max": AnyCodable(15.0)])
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool, true)

        let call2 = FunctionCall(call: "numeric", args: ["value": AnyCodable(20.0), "max": AnyCodable(15.0)])
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: call2, surface: surface) as? Bool, false)
        
        let call3 = FunctionCall(call: "numeric", args: ["value": AnyCodable("10"), "min": AnyCodable(5.0)])
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: call3, surface: surface) as? Bool, true)
    }

    func testEmail() async {
        let call = FunctionCall(call: "email", args: ["value": AnyCodable("test@example.com")])
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool, true)

        let call2 = FunctionCall(call: "email", args: ["value": AnyCodable("invalid-email")])
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: call2, surface: surface) as? Bool, false)
    }

    func testFormatString() async {
        surface.setValue(at: "/user/name", value: "Alice")
        let call = FunctionCall(call: "formatString", args: ["value": AnyCodable("Hello, ${/user/name}!")])
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? String, "Hello, Alice!")
    }

    func testFormatNumber() async {
        let call = FunctionCall(call: "formatNumber", args: ["value": AnyCodable(1234.567), "decimals": AnyCodable(2.0), "grouping": AnyCodable(true)])
        let result = A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? String
        // Locale dependent, but should contain 1,234.57 or 1.234,57
        XCTAssertTrue(result?.contains("1") ?? false)
        XCTAssertTrue(result?.contains("234") ?? false)
        XCTAssertTrue(result?.contains("57") ?? false)
    }

    func testFormatCurrency() async {
        let call = FunctionCall(call: "formatCurrency", args: ["value": AnyCodable(1234.56), "currency": AnyCodable("USD")])
        let result = A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? String
        XCTAssertTrue(result?.contains("$") ?? false)
        XCTAssertTrue(result?.contains("1,234.56") ?? result?.contains("1.234,56") ?? false)
    }

    func testFormatDate() async {
        // Use a fixed timestamp for testing: 2026-02-26T12:00:00Z (roughly)
        let timestamp = 1772107200.0 // Thu Feb 26 2026 12:00:00 UTC
        let call = FunctionCall(call: "formatDate", args: ["value": AnyCodable(timestamp), "format": AnyCodable("yyyy-MM-dd")])
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? String, "2026-02-26")
    }

    func testPluralize() async {
        let args: [String: AnyCodable] = [
            "value": AnyCodable(1.0),
            "one": AnyCodable("item"),
            "other": AnyCodable("items")
        ]
        let call = FunctionCall(call: "pluralize", args: args)
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? String, "item")

        let args2: [String: AnyCodable] = [
            "value": AnyCodable(2.0),
            "one": AnyCodable("item"),
            "other": AnyCodable("items")
        ]
        let call2 = FunctionCall(call: "pluralize", args: args2)
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: call2, surface: surface) as? String, "items")
    }

    func testLogical() async {
        let andCall = FunctionCall(call: "and", args: ["values": AnyCodable([true, true])])
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: andCall, surface: surface) as? Bool, true)

        let andCall2 = FunctionCall(call: "and", args: ["values": AnyCodable([true, false])])
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: andCall2, surface: surface) as? Bool, false)

        let orCall = FunctionCall(call: "or", args: ["values": AnyCodable([true, false])])
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: orCall, surface: surface) as? Bool, true)

        let notCall = FunctionCall(call: "not", args: ["value": AnyCodable(true)])
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: notCall, surface: surface) as? Bool, false)
    }
    
    func testNestedFunctionCall() async {
        // not(isRequired(value: "")) -> not(false) -> true
        let innerCall: [String: Sendable] = [
            "call": "required",
            "args": ["value": ""]
        ]
        let outerCall = FunctionCall(call: "not", args: ["value": AnyCodable(innerCall)])
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: outerCall, surface: surface) as? Bool, true)
    }
    
    func testDataBindingInFunctionCall() async {
        surface.setValue(at: "/test/val", value: "hello")
        let binding: [String: Sendable] = ["path": "/test/val"]
        let call = FunctionCall(call: "required", args: ["value": AnyCodable(binding)])
        XCTAssertEqual(A2UIFunctionEvaluator.evaluate(call: call, surface: surface) as? Bool, true)
    }

    func testCheckableLogic() async {
        surface.setValue(at: "/email", value: "invalid")
        let condition = BoundValue<Bool>(functionCall: FunctionCall(call: "email", args: ["value": AnyCodable(["path": "/email"])]))
        let check = CheckRule(condition: condition, message: "Invalid email")
        
        let error = errorMessage(surface: surface, checks: [check])
        XCTAssertEqual(error, "Invalid email")
        
        surface.setValue(at: "/email", value: "test@example.com")
        let noError = errorMessage(surface: surface, checks: [check])
        XCTAssertNil(noError)
    }
}
