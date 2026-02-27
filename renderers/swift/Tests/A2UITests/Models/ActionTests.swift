import Testing
@testable import A2UI
import Foundation

struct ActionTests {
    @Test func actionDecodeEncode() throws {
        let eventJson = """
        {
            "event": {
                "name": "click",
                "context": {"key": "val"}
            }
        }
        """.data(using: .utf8)!
        let eventAction = try JSONDecoder().decode(Action.self, from: eventJson)
        if case let .event(name, context) = eventAction {
            #expect(name == "click")
            #expect(context?["key"] == AnyCodable("val"))
        } else {
            Issue.record("Expected event action")
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
        
        // Error case (v0.8 legacy format should now fail)
        let legacyJson = """
        {
            "name": "submit",
            "context": {"key": "val"}
        }
        """.data(using: .utf8)!
        #expect(throws: Error.self) { try JSONDecoder().decode(Action.self, from: legacyJson) }
        
        // Encoding Event Action
        let encodedEvent = try JSONEncoder().encode(eventAction)
        let decodedEvent = try JSONDecoder().decode(Action.self, from: encodedEvent)
        if case let .event(name, context) = decodedEvent {
            #expect(name == "click")
            #expect(context?["key"] == AnyCodable("val"))
        }
    }
}
