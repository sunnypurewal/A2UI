import Testing
@testable import A2UI
import Foundation

struct ActionTests {
    @Test func actionDecodeEncode() throws {
        let customJson = """
        {
            "name": "submit",
            "context": {"key": "val"}
        }
        """.data(using: .utf8)!
        let customAction = try JSONDecoder().decode(Action.self, from: customJson)
        if case let .custom(name, context) = customAction {
            #expect(name == "submit")
            #expect(context?["key"] == AnyCodable("val"))
        } else {
            Issue.record("Expected custom action")
        }
        
        let eventJson = """
        {
            "event": {
                "name": "click",
                "context": {"key": "val"}
            }
        }
        """.data(using: .utf8)!
        let eventAction = try JSONDecoder().decode(Action.self, from: eventJson)
        if case let .custom(name, context) = eventAction {
            #expect(name == "click")
            #expect(context?["key"] == AnyCodable("val"))
        } else {
            Issue.record("Expected custom action from event")
        }
        
        let dataUpdateJson = """
        {
            "dataUpdate": {
                "path": "user.name",
                "contents": "John"
            }
        }
        """.data(using: .utf8)!
        let dataUpdateAction = try JSONDecoder().decode(Action.self, from: dataUpdateJson)
        if case let .dataUpdate(du) = dataUpdateAction {
            #expect(du.path == "user.name")
            #expect(du.contents == AnyCodable("John"))
        } else {
            Issue.record("Expected dataUpdate action")
        }
        
        let functionCallJson = """
        {
            "functionCall": {
                "call": "doSomething"
            }
        }
        """.data(using: .utf8)!
        let functionCallAction = try JSONDecoder().decode(Action.self, from: functionCallJson)
        if case let .functionCall(fc) = functionCallAction {
            #expect(fc.call == "doSomething")
        } else {
            Issue.record("Expected functionCall action")
        }
        
        // Error case
        let invalidJson = """
        { "invalid": true }
        """.data(using: .utf8)!
        #expect(throws: Error.self) { try JSONDecoder().decode(Action.self, from: invalidJson) }
        
        // Encoding Custom Action
        let encodedCustom = try JSONEncoder().encode(customAction)
        let decodedCustom = try JSONDecoder().decode(Action.self, from: encodedCustom)
        if case let .custom(name, context) = decodedCustom {
            #expect(name == "submit")
            #expect(context?["key"] == AnyCodable("val"))
        }
    }
}
