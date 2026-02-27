import XCTest
@testable import A2UI

final class ActionTests: XCTestCase {
    func testActionDecodeEncode() throws {
        let customJson = """
        {
            "name": "submit",
            "context": {"key": "val"}
        }
        """.data(using: .utf8)!
        let customAction = try JSONDecoder().decode(Action.self, from: customJson)
        if case let .custom(name, context) = customAction {
            XCTAssertEqual(name, "submit")
            XCTAssertEqual(context?["key"], AnyCodable("val"))
        } else {
            XCTFail()
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
            XCTAssertEqual(name, "click")
            XCTAssertEqual(context?["key"], AnyCodable("val"))
        } else {
            XCTFail()
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
            XCTAssertEqual(du.path, "user.name")
            XCTAssertEqual(du.contents, AnyCodable("John"))
        } else {
            XCTFail()
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
            XCTAssertEqual(fc.call, "doSomething")
        } else {
            XCTFail()
        }
        
        // Error case
        let invalidJson = """
        { "invalid": true }
        """.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(Action.self, from: invalidJson))
        
        // Encoding Custom Action
        let encodedCustom = try JSONEncoder().encode(customAction)
        let decodedCustom = try JSONDecoder().decode(Action.self, from: encodedCustom)
        if case let .custom(name, context) = decodedCustom {
            XCTAssertEqual(name, "submit")
            XCTAssertEqual(context?["key"], AnyCodable("val"))
        }
    }
}
