import Testing
import Foundation
@testable import A2UI

struct A2UIParserTests {
    private let parser = A2UIParser()

    // MARK: - Root Message Parsing

    /// Verifies that a `createSurface` message is correctly decoded with all optional fields.
    @Test func parseCreateSurface() throws {
        let json = """
        {
            "createSurface": {
                "surfaceId": "s1",
                "catalogId": "v08",
                "theme": { "primaryColor": "#FF0000" }
            }
        }
        """
        let messages = try parser.parse(line: json)
        
        let firstMessage = try #require(messages.first)
        if case .createSurface(let value) = firstMessage {
            #expect(value.surfaceId == "s1")
            #expect(value.catalogId == "v08")
            #expect(value.theme?["primaryColor"]?.value as? String == "#FF0000")
        } else {
            Issue.record("Failed to decode createSurface")
        }
    }

    /// Verifies that a `deleteSurface` message is correctly decoded.
    @Test func parseDeleteSurface() throws {
        let json = "{\"deleteSurface\": {\"surfaceId\": \"s1\"}}"
        let messages = try parser.parse(line: json)
        
        let firstMessage = try #require(messages.first)
        if case .deleteSurface(let value) = firstMessage {
            #expect(value.surfaceId == "s1")
        } else {
            Issue.record("Failed to decode deleteSurface")
        }
    }

    // MARK: - Component Type Parsing

    /// Verifies that all standard component types (Text, Button, Row, Column, Card)
    /// are correctly decoded via the polymorphic `ComponentType` enum.
    @Test func parseAllComponentTypes() throws {
        let componentsJson = """
        {
            "updateComponents": {
                "surfaceId": "s1",
                "components": [
                    { "id": "t1", "component": { "Text": { "text": "Hello" } } },
                    { "id": "b1", "component": { "Button": { "child": "t1", "action": { "name": "tap" } } } },
                    { "id": "r1", "component": { "Row": { "children": ["t1"] } } },
                    { "id": "c1", "component": { "Column": { "children": ["b1"], "align": "center" } } },
                    { "id": "card1", "component": { "Card": { "child": "r1" } } }
                ]
            }
        }
        """
        let messages = try parser.parse(line: componentsJson)
        
        let firstMessage = try #require(messages.first)
        guard case .surfaceUpdate(let update) = firstMessage else {
            Issue.record("Expected surfaceUpdate")
            return
        }

        #expect(update.components.count == 5)
        
        // Check Row
        if case .row(let props) = update.components[2].component {
            if case .list(let list) = props.children {
                #expect(list == ["t1"])
            } else { Issue.record("Expected list children") }
        } else { Issue.record("Type mismatch for row") }

        // Check Column Alignment
        if case .column(let props) = update.components[3].component {
            #expect(props.align == .center)
        } else { Issue.record("Type mismatch for column") }
    }

    // MARK: - Data Binding & Logic

    /// Verifies that `BoundValue` correctly handles literal strings, literal numbers,
    /// literal booleans, and data model paths.
    @Test func boundValueVariants() throws {
        let json = """
        {
            "updateComponents": {
                "surfaceId": "s1",
                "components": [
                    { "id": "t1", "component": { "Text": { "text": { "path": "/user/name" } } } },
                    { "id": "t2", "component": { "Text": { "text": "Literal" } } }
                ]
            }
        }
        """
        let messages = try parser.parse(line: json)
        
        let firstMessage = try #require(messages.first)
        guard case .surfaceUpdate(let update) = firstMessage else { return }
        
        if case .text(let props) = update.components[0].component {
            #expect(props.text.path == "/user/name")
            #expect(props.text.literal == nil)
        }
        
        if case .text(let props) = update.components[1].component {
            #expect(props.text.literal == "Literal")
            #expect(props.text.path == nil)
        }
    }

    // MARK: - Error Handling & Edge Cases

    /// Verifies that the parser decodes unknown component types as .custom instead of throwing.
    @Test func parseUnknownComponent() throws {
        let json = "{\"updateComponents\": {\"surfaceId\": \"s1\", \"components\": [{\"id\": \"1\", \"component\": {\"Unknown\": {\"foo\":\"bar\"}}}]}}"
        let messages = try parser.parse(line: json)
        
        let firstMessage = try #require(messages.first)
        if case .surfaceUpdate(let update) = firstMessage,
           case .custom(let name, let props) = update.components.first?.component {
            #expect(name == "Unknown")
            #expect(props["foo"]?.value as? String == "bar")
        } else {
            Issue.record("Should have decoded as .custom component")
        }
    }

    /// Verifies that the parser can handle multiple JSON objects on a single line,
    /// even if separated by commas (common in some non-standard JSONL producers).
    @Test func parseCommaSeparatedObjectsOnOneLine() throws {
        let json = """
        {"updateDataModel":{"surfaceId":"s1"}},{"updateComponents":{"surfaceId":"s1","components":[]}}
        """
        let messages = try parser.parse(line: json)
        #expect(messages.count == 2)
        
        if case .dataModelUpdate = messages[0] {} else { Issue.record("First message should be dataModelUpdate") }
        if case .surfaceUpdate = messages[1] {} else { Issue.record("Second message should be surfaceUpdate") }
    }

    /// Verifies that the parser correctly returns an empty array for empty lines in a JSONL stream.
    @Test func parseEmptyLine() throws {
        #expect(try parser.parse(line: "").isEmpty)
        #expect(try parser.parse(line: "   ").isEmpty)
        #expect(try parser.parse(line: "\n").isEmpty)
    }

    @Test func parseArrayDirectly() throws {
        let json = "[{\"deleteSurface\":{\"surfaceId\":\"s1\"}},{\"deleteSurface\":{\"surfaceId\":\"s2\"}}]"
        let messages = try parser.parse(line: json)
        #expect(messages.count == 2)
    }

    @Test func parseInvalidJson() throws {
        #expect(throws: (any Error).self) {
            try parser.parse(line: "not json")
        }
    }

    @Test func parseChunkWithError() throws {
        var remainder = ""
        let chunk = "{\"deleteSurface\":{\"surfaceId\":\"1\"}}\ninvalid json\n{\"deleteSurface\":{\"surfaceId\":\"2\"}}\n"
        let messages = parser.parse(chunk: chunk, remainder: &remainder)
        #expect(messages.count == 2)
        #expect(remainder.isEmpty)
    }

    @Test func parseMultipleLinesInChunk() throws {
        var remainder = ""
        let chunk = "{\"deleteSurface\":{\"surfaceId\":\"1\"}}\n{\"deleteSurface\":{\"surfaceId\":\"2\"}}\n"
        let messages = parser.parse(chunk: chunk, remainder: &remainder)
        #expect(messages.count == 2)
    }

    // MARK: - Children Compatibility Tests

    @Test func childrenDirectArray() throws {
        let json = """
        {
            "version": "v0.10",
            "updateComponents": {
                "surfaceId": "s1",
                "components": [
                    { "id": "r1", "component": { "Row": { "children": ["t1", "t2"] } } }
                ]
            }
        }
        """
        let messages = try parser.parse(line: json)
        
        let firstMessage = try #require(messages.first)
        guard case .surfaceUpdate(let update) = firstMessage else {
            Issue.record("Expected surfaceUpdate")
            return
        }
        
        if case .row(let props) = update.components[0].component {
            if case .list(let list) = props.children {
                #expect(list == ["t1", "t2"])
            } else {
                Issue.record("Expected .list")
            }
        } else {
            Issue.record("Expected .row")
        }
    }

    @Test func childrenLegacyExplicitList() throws {
        let json = """
        {
            "version": "v0.10",
            "updateComponents": {
                "surfaceId": "s1",
                "components": [
                    { "id": "r1", "component": { "Row": { "children": { "explicitList": ["t1", "t2"] } } } }
                ]
            }
        }
        """
        let messages = try parser.parse(line: json)
        
        let firstMessage = try #require(messages.first)
        guard case .surfaceUpdate(let update) = firstMessage else {
            Issue.record("Expected surfaceUpdate")
            return
        }
        
        if case .row(let props) = update.components[0].component {
            if case .list(let list) = props.children {
                #expect(list == ["t1", "t2"])
            } else {
                Issue.record("Expected .list")
            }
        } else {
            Issue.record("Expected .row")
        }
    }

    @Test func childrenTemplate() throws {
        let json = """
        {
            "version": "v0.10",
            "updateComponents": {
                "surfaceId": "s1",
                "components": [
                    { "id": "r1", "component": { "Row": { "children": { "componentId": "tpl", "path": "/items" } } } }
                ]
            }
        }
        """
        let messages = try parser.parse(line: json)
        
        let firstMessage = try #require(messages.first)
        guard case .surfaceUpdate(let update) = firstMessage else {
            Issue.record("Expected surfaceUpdate")
            return
        }
        
        if case .row(let props) = update.components[0].component {
            if case .template(let template) = props.children {
                #expect(template.componentId == "tpl")
                #expect(template.path == "/items")
            } else {
                Issue.record("Expected .template")
            }
        } else {
            Issue.record("Expected .row")
        }
    }

    // MARK: - Helper Utility Tests

    /// Verifies that the `AnyCodable` helper correctly handles various JSON types
    /// (String, Double, Bool, Dictionary) without data loss.
    @Test func anyCodable() throws {
        let dict: [String: Sendable] = ["s": "str", "n": 1.0, "b": true]
        let anyCodable = AnyCodable(dict)
        
        let encoded = try JSONEncoder().encode(anyCodable)
        let decoded = try JSONDecoder().decode(AnyCodable.self, from: encoded)
        
        let decodedDict = decoded.value as? [String: Sendable]
        #expect(decodedDict?["s"] as? String == "str")
        #expect(decodedDict?["n"] as? Double == 1.0)
        #expect(decodedDict?["b"] as? Bool == true)
    }

    /// Verifies that an A2UIMessage can be encoded back to JSON and re-decoded
    /// without loss of information (Symmetric Serialization).
    @Test func symmetricEncoding() throws {
        let originalJson = "{\"deleteSurface\":{\"surfaceId\":\"s1\"}}"
        let messages = try parser.parse(line: originalJson)
        let message = try #require(messages.first)
        
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(message)
        let decodedMessage = try JSONDecoder().decode(A2UIMessage.self, from: encodedData)
        
        if case .deleteSurface(let value) = decodedMessage {
            #expect(value.surfaceId == "s1")
        } else {
            Issue.record()
        }
    }

    /// Verifies that all component types can be encoded and decoded without loss.
    @Test func symmetricComponentEncoding() throws {
        let action = Action.custom(name: "testAction", context: nil)
        let boundStr = BoundValue<String>(literal: "test")
        let boundBool = BoundValue<Bool>(literal: true)
        let boundNum = BoundValue<Double>(literal: 42)
        let children = Children.list(["c1"])

        let components: [ComponentType] = [
            .text(.init(text: boundStr, variant: .h1)),
            .button(.init(child: "C", action: action, variant: .primary)),
            .row(.init(children: children, justify: .stretch, align: .center)),
            .column(.init(children: children, justify: .start, align: .start)),
            .card(.init(child: "C")),
            .image(.init(url: boundStr, fit: .cover, variant: nil)),
            .icon(.init(name: boundStr)),
            .video(.init(url: boundStr)),
            .audioPlayer(.init(url: boundStr, description: nil)),
            .divider(.init(axis: .horizontal)),
            .list(.init(children: children, direction: "vertical", align: nil)),
            .tabs(.init(tabs: [TabItem(title: boundStr, child: "c1")])),
            .textField(.init(label: boundStr, value: boundStr, variant: .shortText)),
            .checkBox(.init(label: boundStr, value: boundBool)),
            .slider(.init(label: boundStr, min: 0, max: 100, value: boundNum)),
            .custom("CustomComp", ["key": AnyCodable("val")])
        ]
        
        for comp in components {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            let encoded = try encoder.encode(comp)
            
            let decoded = try JSONDecoder().decode(ComponentType.self, from: encoded)
            #expect(comp.typeName == decoded.typeName)
            
            // Re-encode decoded to ensure symmetry
            let reEncoded = try encoder.encode(decoded)
            #expect(encoded == reEncoded)
        }
    }

    /// Verifies that the streaming logic correctly handles split lines across multiple chunks.
    @Test func streamingRemainderLogic() {
        var remainder = ""
        let chunk = "{\"deleteSurface\":{\"surfaceId\":\"1\"}}\n{\"beginRe"
        var messages = parser.parse(chunk: chunk, remainder: &remainder)
        
        #expect(messages.count == 1)
        #expect(remainder == "{\"beginRe")
        
        messages = parser.parse(chunk: "ndering\":{\"surfaceId\":\"1\",\"root\":\"r\"}}\n", remainder: &remainder)
        #expect(messages.count == 1)
        #expect(remainder == "")
    }
}
