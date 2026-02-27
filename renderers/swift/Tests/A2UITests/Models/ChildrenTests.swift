import Testing
@testable import A2UI
import Foundation

struct ChildrenTests {
    @Test func childrenDecodeEncode() throws {
        let listJson = #"["child1", "child2"]"#.data(using: .utf8)!
        let listVal = try JSONDecoder().decode(Children.self, from: listJson)
        if case let .list(items) = listVal {
            #expect(items == ["child1", "child2"])
        } else { Issue.record("Expected list children") }
        
        let templateJson = #"{"componentId": "item", "path": "items"}"#.data(using: .utf8)!
        let templateVal = try JSONDecoder().decode(Children.self, from: templateJson)
        if case let .template(t) = templateVal {
            #expect(t.componentId == "item")
            #expect(t.path == "items")
        } else { Issue.record("Expected template children") }
        
        // Legacy wrappers
        let explicitListJson = #"{"explicitList": ["child1"]}"#.data(using: .utf8)!
        let explicitListVal = try JSONDecoder().decode(Children.self, from: explicitListJson)
        if case let .list(items) = explicitListVal {
            #expect(items == ["child1"])
        } else { Issue.record("Expected list children from explicitList") }
        
        let explicitTemplateJson = #"{"template": {"componentId": "c", "path": "p"}}"#.data(using: .utf8)!
        let explicitTemplateVal = try JSONDecoder().decode(Children.self, from: explicitTemplateJson)
        if case let .template(t) = explicitTemplateVal {
            #expect(t.componentId == "c")
        } else { Issue.record("Expected template children from template wrapper") }
        
        // Error
        let invalidJson = #"{"invalid": true}"#.data(using: .utf8)!
        #expect(throws: Error.self) { try JSONDecoder().decode(Children.self, from: invalidJson) }
        
        // Encode
        let encodedList = try JSONEncoder().encode(listVal)
        let decodedList = try JSONDecoder().decode(Children.self, from: encodedList)
        if case let .list(items) = decodedList { #expect(items == ["child1", "child2"]) }
        
        let encodedTemplate = try JSONEncoder().encode(templateVal)
        let decodedTemplate = try JSONDecoder().decode(Children.self, from: encodedTemplate)
        if case let .template(t) = decodedTemplate { #expect(t.componentId == "item") }
    }
}
