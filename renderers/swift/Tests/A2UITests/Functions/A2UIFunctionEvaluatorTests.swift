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
		
		let lenInvalid2 = FunctionCall(call: "length", args: ["value": AnyCodable("123"), "min": AnyCodable("J")])
		#expect(A2UIStandardFunctions.evaluate(call: lenInvalid2, surface: surface) as? Bool == false)

        let numInvalid = FunctionCall(call: "numeric", args: ["value": AnyCodable(123)])
        #expect(A2UIStandardFunctions.evaluate(call: numInvalid, surface: surface) as? Bool == false)

        let andInvalid = FunctionCall(call: "and", args: ["values": AnyCodable(123)])
        #expect(A2UIStandardFunctions.evaluate(call: andInvalid, surface: surface) as? Bool == false)
        
        let orInvalid = FunctionCall(call: "or", args: ["values": AnyCodable([true] as [Sendable])])
        #expect(A2UIStandardFunctions.evaluate(call: orInvalid, surface: surface) as? Bool == false)
        
        let notInvalid = FunctionCall(call: "not", args: ["value": AnyCodable(123)])
        #expect(A2UIStandardFunctions.evaluate(call: notInvalid, surface: surface) as? Bool == false)
		
		let formatDateInvalid = FunctionCall(call: "formatDate", args: ["value": AnyCodable(123)])
		#expect(A2UIStandardFunctions.evaluate(call: formatDateInvalid, surface: surface) as? String == "")
    }

    @Test func resolveDynamicValueEdgeCases() {
        let arrVal: [Sendable] = [["path": "/test/val"] as [String: Sendable]]
        surface.setValue(at: "/test/val", value: "resolved")
        
        let result = A2UIStandardFunctions.resolveDynamicValue(arrVal, surface: surface) as? [Any]
        #expect(result?.first as? String == "resolved")
        
        let nullRes = A2UIStandardFunctions.resolveDynamicValue(NSNull(), surface: surface) as? NSNull
        #expect(nullRes != nil)
		
		let nilRes = A2UIStandardFunctions.resolveDynamicValue(nil, surface: surface) as? NSNull
		#expect(nilRes == nil)
		
		let nonDict = "not a dict"
		let nonDictRes = A2UIStandardFunctions.resolveDynamicValue(nonDict, surface: surface)
		#expect(nonDictRes as? String == nonDict)
		
		let arrayWithNonDict = ["string in array"] as [Sendable]
		let arrayWithNonDictRes = A2UIStandardFunctions.resolveDynamicValue(arrayWithNonDict, surface: surface) as? [Any]
		#expect(arrayWithNonDictRes?.first as? String == "string in array")
		#expect(arrayWithNonDictRes?.count == 1)
    }

    @Test func makeSendableTests() async {
        // Literals
        #expect(A2UIStandardFunctions.makeSendable("string") as? String == "string")
        #expect(A2UIStandardFunctions.makeSendable(123) as? Int == 123)
        #expect(A2UIStandardFunctions.makeSendable(123.45) as? Double == 123.45)
        #expect(A2UIStandardFunctions.makeSendable(true) as? Bool == true)
        
        let date = Date()
        #expect(A2UIStandardFunctions.makeSendable(date) as? Date == date)
        
        // NSNull and JSONNull
        #expect(A2UIStandardFunctions.makeSendable(NSNull()) is JSONNull)
        #expect(A2UIStandardFunctions.makeSendable(JSONNull()) is JSONNull)
        
        // Dictionaries
        let dict: [String: Any] = ["key": "value", "num": 1]
        let sendableDict = A2UIStandardFunctions.makeSendable(dict) as? [String: Sendable]
        #expect(sendableDict?["key"] as? String == "value")
        #expect(sendableDict?["num"] as? Int == 1)
        
        // Arrays
        let array: [Any] = ["string", 1, true]
        let sendableArray = A2UIStandardFunctions.makeSendable(array) as? [Sendable]
        #expect(sendableArray?[0] as? String == "string")
        #expect(sendableArray?[1] as? Int == 1)
        #expect(sendableArray?[2] as? Bool == true)
        
        // Nested Structures
        let nested: [String: Any] = [
            "arr": ["nested", ["inner": "dict"]] as [Any]
        ]
        let sendableNested = A2UIStandardFunctions.makeSendable(nested) as? [String: Sendable]
        let nestedArr = sendableNested?["arr"] as? [Sendable]
        #expect(nestedArr?[0] as? String == "nested")
        let innerDict = nestedArr?[1] as? [String: Sendable]
        #expect(innerDict?["inner"] as? String == "dict")
        
        // Fallback
        struct Unsendable {}
        #expect(A2UIStandardFunctions.makeSendable(Unsendable()) is JSONNull)
    }
}
