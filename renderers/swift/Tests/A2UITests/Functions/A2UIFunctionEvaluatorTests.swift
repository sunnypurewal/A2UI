import Foundation
import Testing
@testable import A2UI

@MainActor
struct A2UIFunctionEvaluatorTests {
    private let surface = SurfaceState(id: "test")

    @Test func nestedFunctionCall() async {
        let innerCall: [String: Sendable] = [
            "call": "required",
            "args": ["value": ""]
        ]
        let outerCall = FunctionCall.not(value: innerCall)
        #expect(A2UIStandardFunctions.evaluate(call: outerCall, surface: surface) as? Bool == true)
    }
    
    @Test func dataBindingInFunctionCall() async {
        surface.setValue(at: "/test/val", value: "hello")
        let binding: [String: Sendable] = ["path": "/test/val"]
        let call = FunctionCall.required(value: binding)
        #expect(A2UIStandardFunctions.evaluate(call: call, surface: surface) as? Bool == true)
    }

    @Test func arrayResolutionInFunctionCall() async {
        surface.setValue(at: "/test/bool1", value: true)
        surface.setValue(at: "/test/bool2", value: false)
        
        let binding1: [String: Sendable] = ["path": "/test/bool1"]
        let binding2: [String: Sendable] = ["path": "/test/bool2"]
        
        let call = FunctionCall.and(values: [binding1, binding2])
        #expect(A2UIStandardFunctions.evaluate(call: call, surface: surface) as? Bool == false)
        
        surface.setValue(at: "/test/bool2", value: true)
        #expect(A2UIStandardFunctions.evaluate(call: call, surface: surface) as? Bool == true)
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

    @Test func missingOrInvalidFunctionsAndArguments() async {
        let unknown = FunctionCall(call: "someRandomFunction")
        #expect(A2UIStandardFunctions.evaluate(call: unknown, surface: surface) == nil)
        
        let reqInvalid = FunctionCall(call: "required")
        #expect(A2UIStandardFunctions.evaluate(call: reqInvalid, surface: surface) as? Bool == false)
        
        let emailInvalid = FunctionCall(call: "email", args: ["value": AnyCodable(123)])
        #expect(A2UIStandardFunctions.evaluate(call: emailInvalid, surface: surface) as? Bool == false)
        
        let lenInvalid1 = FunctionCall(call: "length", args: ["value": AnyCodable(123), "min": AnyCodable(1)])
        #expect(A2UIStandardFunctions.evaluate(call: lenInvalid1, surface: surface) as? Bool == false)

        let numInvalid = FunctionCall(call: "numeric", args: ["value": AnyCodable(123)])
        #expect(A2UIStandardFunctions.evaluate(call: numInvalid, surface: surface) as? Bool == false)

        let andInvalid = FunctionCall(call: "and", args: ["values": AnyCodable(123)])
        #expect(A2UIStandardFunctions.evaluate(call: andInvalid, surface: surface) as? Bool == false)
        
        let orInvalid = FunctionCall(call: "or", args: ["values": AnyCodable([true] as [Sendable])])
        #expect(A2UIStandardFunctions.evaluate(call: orInvalid, surface: surface) as? Bool == false)
        
        let notInvalid = FunctionCall(call: "not", args: ["value": AnyCodable(123)])
        #expect(A2UIStandardFunctions.evaluate(call: notInvalid, surface: surface) as? Bool == false)
    }

    @Test func resolveDynamicValueEdgeCases() async {
        let arrVal: [Sendable] = [["path": "/test/val"] as [String: Sendable]]
        surface.setValue(at: "/test/val", value: "resolved")
        
        let result = A2UIStandardFunctions.resolveDynamicValue(arrVal, surface: surface) as? [Any]
        #expect(result?.first as? String == "resolved")
        
        let nullRes = A2UIStandardFunctions.resolveDynamicValue(NSNull(), surface: surface) as? NSNull
        #expect(nullRes != nil)
    }
}
