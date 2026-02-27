import XCTest
@testable import A2UI

final class ChildrenTests: XCTestCase {
    func testChildrenDecodeEncode() throws {
        let listJson = #"["child1", "child2"]"#.data(using: .utf8)!
        let listVal = try JSONDecoder().decode(Children.self, from: listJson)
        if case let .list(items) = listVal {
            XCTAssertEqual(items, ["child1", "child2"])
        } else { XCTFail() }
        
        let templateJson = #"{"componentId": "item", "path": "items"}"#.data(using: .utf8)!
        let templateVal = try JSONDecoder().decode(Children.self, from: templateJson)
        if case let .template(t) = templateVal {
            XCTAssertEqual(t.componentId, "item")
            XCTAssertEqual(t.path, "items")
        } else { XCTFail() }
        
        // Legacy wrappers
        let explicitListJson = #"{"explicitList": ["child1"]}"#.data(using: .utf8)!
        let explicitListVal = try JSONDecoder().decode(Children.self, from: explicitListJson)
        if case let .list(items) = explicitListVal {
            XCTAssertEqual(items, ["child1"])
        } else { XCTFail() }
        
        let explicitTemplateJson = #"{"template": {"componentId": "c", "path": "p"}}"#.data(using: .utf8)!
        let explicitTemplateVal = try JSONDecoder().decode(Children.self, from: explicitTemplateJson)
        if case let .template(t) = explicitTemplateVal {
            XCTAssertEqual(t.componentId, "c")
        } else { XCTFail() }
        
        // Error
        let invalidJson = #"{"invalid": true}"#.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(Children.self, from: invalidJson))
        
        // Encode
        let encodedList = try JSONEncoder().encode(listVal)
        let decodedList = try JSONDecoder().decode(Children.self, from: encodedList)
        if case let .list(items) = decodedList { XCTAssertEqual(items, ["child1", "child2"]) }
        
        let encodedTemplate = try JSONEncoder().encode(templateVal)
        let decodedTemplate = try JSONDecoder().decode(Children.self, from: encodedTemplate)
        if case let .template(t) = decodedTemplate { XCTAssertEqual(t.componentId, "item") }
    }
}
