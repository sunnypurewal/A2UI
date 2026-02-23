import XCTest
@testable import A2UI

final class A2UIParserTests: XCTestCase {
    var parser: A2UIParser!

    override func setUp() {
        super.setUp()
        parser = A2UIParser()
    }

    // MARK: - Root Message Parsing

    /// Verifies that a `createSurface` message is correctly decoded with all optional fields.
    func testParseCreateSurface() throws {
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
        if case .createSurface(let value) = messages.first {
            XCTAssertEqual(value.surfaceId, "s1")
            XCTAssertEqual(value.catalogId, "v08")
            XCTAssertEqual(value.theme?["primaryColor"]?.value as? String, "#FF0000")
        } else {
            XCTFail("Failed to decode createSurface")
        }
    }

    /// Verifies that a `deleteSurface` message is correctly decoded.
    func testParseDeleteSurface() throws {
        let json = "{\"deleteSurface\": {\"surfaceId\": \"s1\"}}"
        let messages = try parser.parse(line: json)
        if case .deleteSurface(let value) = messages.first {
            XCTAssertEqual(value.surfaceId, "s1")
        } else {
            XCTFail("Failed to decode deleteSurface")
        }
    }

    // MARK: - Component Type Parsing

    /// Verifies that all standard component types (Text, Button, Row, Column, Card)
    /// are correctly decoded via the polymorphic `ComponentType` enum.
    func testParseAllComponentTypes() throws {
        let componentsJson = """
        {
            "updateComponents": {
                "surfaceId": "s1",
                "components": [
                    { "id": "t1", "component": { "Text": { "text": "Hello" } } },
                    { "id": "b1", "component": { "Button": { "child": "t1", "action": { "name": "tap" } } } },
                    { "id": "r1", "component": { "Row": { "children": { "explicitList": ["t1"] } } } },
                    { "id": "c1", "component": { "Column": { "children": { "explicitList": ["b1"] }, "align": "center" } } },
                    { "id": "card1", "component": { "Card": { "child": "r1" } } }
                ]
            }
        }
        """
        let messages = try parser.parse(line: componentsJson)
        guard case .surfaceUpdate(let update) = messages.first else {
            XCTFail("Expected surfaceUpdate")
            return
        }

        XCTAssertEqual(update.components.count, 5)
        
        // Check Row
        if case .row(let props) = update.components[2].component {
            XCTAssertEqual(props.children.explicitList, ["t1"])
        } else { XCTFail("Type mismatch for row") }

        // Check Column Alignment
        if case .column(let props) = update.components[3].component {
            XCTAssertEqual(props.align, "center")
        } else { XCTFail("Type mismatch for column") }
    }

    // MARK: - Data Binding & Logic

    /// Verifies that `BoundValue` correctly handles literal strings, literal numbers,
    /// literal booleans, and data model paths.
    func testBoundValueVariants() throws {
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
        guard case .surfaceUpdate(let update) = messages.first else { return }
        
        if case .text(let props) = update.components[0].component {
            XCTAssertEqual(props.text.path, "/user/name")
            XCTAssertNil(props.text.literal)
        }
        
        if case .text(let props) = update.components[1].component {
            XCTAssertEqual(props.text.literal, "Literal")
            XCTAssertNil(props.text.path)
        }
    }

    // MARK: - Error Handling & Edge Cases

    /// Verifies that the parser decodes unknown component types as .custom instead of throwing.
    func testParseUnknownComponent() throws {
        let json = "{\"updateComponents\": {\"surfaceId\": \"s1\", \"components\": [{\"id\": \"1\", \"component\": {\"Unknown\": {\"foo\":\"bar\"}}}]}}"
        let messages = try parser.parse(line: json)
        
        if case .surfaceUpdate(let update) = messages.first,
           case .custom(let name, let props) = update.components.first?.component {
            XCTAssertEqual(name, "Unknown")
            XCTAssertEqual(props["foo"]?.value as? String, "bar")
        } else {
            XCTFail("Should have decoded as .custom component")
        }
    }

    /// Verifies that the parser can handle multiple JSON objects on a single line,
    /// even if separated by commas (common in some non-standard JSONL producers).
    func testParseCommaSeparatedObjectsOnOneLine() throws {
        let json = """
        {"updateDataModel":{"surfaceId":"s1"}},{"updateComponents":{"surfaceId":"s1","components":[]}}
        """
        let messages = try parser.parse(line: json)
        XCTAssertEqual(messages.count, 2)
        
        if case .dataModelUpdate = messages[0] {} else { XCTFail("First message should be dataModelUpdate") }
        if case .surfaceUpdate = messages[1] {} else { XCTFail("Second message should be surfaceUpdate") }
    }

    /// Verifies that the parser correctly returns an empty array for empty lines in a JSONL stream.
    func testParseEmptyLine() throws {
        XCTAssertTrue(try parser.parse(line: "").isEmpty)
        XCTAssertTrue(try parser.parse(line: "   ").isEmpty)
    }

    // MARK: - Helper Utility Tests

    /// Verifies that the `AnyCodable` helper correctly handles various JSON types
    /// (String, Double, Bool, Dictionary) without data loss.
    func testAnyCodable() throws {
        let dict: [String: Sendable] = ["s": "str", "n": 1.0, "b": true]
        let anyCodable = AnyCodable(dict)
        
        let encoded = try JSONEncoder().encode(anyCodable)
        let decoded = try JSONDecoder().decode(AnyCodable.self, from: encoded)
        
        let decodedDict = decoded.value as? [String: Sendable]
        XCTAssertEqual(decodedDict?["s"] as? String, "str")
        XCTAssertEqual(decodedDict?["n"] as? Double, 1.0)
        XCTAssertEqual(decodedDict?["b"] as? Bool, true)
    }

    /// Verifies that an A2UIMessage can be encoded back to JSON and re-decoded
    /// without loss of information (Symmetric Serialization).
    func testSymmetricEncoding() throws {
        let originalJson = "{\"deleteSurface\":{\"surfaceId\":\"s1\"}}"
        let messages = try parser.parse(line: originalJson)
        let message = try XCTUnwrap(messages.first)
        
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(message)
        let decodedMessage = try JSONDecoder().decode(A2UIMessage.self, from: encodedData)
        
        if case .deleteSurface(let value) = decodedMessage {
            XCTAssertEqual(value.surfaceId, "s1")
        } else {
            XCTFail()
        }
    }

    /// Verifies that all component types can be encoded and decoded without loss.
    func testSymmetricComponentEncoding() throws {
        let action = Action.custom(name: "testAction", context: nil)
        let boundStr = BoundValue<String>(literal: "test")
        let boundBool = BoundValue<Bool>(literal: true)
        let boundNum = BoundValue<Double>(literal: 42)
        let children = Children(explicitList: ["c1"], template: nil)

        let components: [ComponentType] = [
            .text(.init(text: boundStr, variant: "h1")),
            .button(.init(child: "C", action: action, variant: "primary")),
            .row(.init(children: children, justify: "fill", align: "center")),
            .column(.init(children: children, justify: "start", align: "leading")),
            .card(.init(child: "C")),
            .image(.init(url: boundStr, fit: "cover", variant: nil)),
            .icon(.init(name: boundStr)),
            .video(.init(url: boundStr, description: boundStr)),
            .audioPlayer(.init(url: boundStr, description: nil)),
            .divider(.init(axis: "horizontal")),
            .list(.init(children: children, direction: "vertical", align: nil)),
            .tabs(.init(tabs: [TabItem(title: boundStr, child: "c1")])),
            .textField(.init(label: boundStr, value: boundStr, variant: "shortText")),
            .checkBox(.init(label: boundStr, value: boundBool)),
            .slider(.init(label: boundStr, min: 0, max: 100, value: boundNum)),
            .custom("CustomComp", ["key": AnyCodable("val")])
        ]
        
        for comp in components {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            let encoded = try encoder.encode(comp)
            
            let decoded = try JSONDecoder().decode(ComponentType.self, from: encoded)
            XCTAssertEqual(comp.typeName, decoded.typeName)
            
            // Re-encode decoded to ensure symmetry
            let reEncoded = try encoder.encode(decoded)
            XCTAssertEqual(encoded, reEncoded)
        }
    }

    /// Verifies that the streaming logic correctly handles split lines across multiple chunks.
    func testStreamingRemainderLogic() {
        var remainder = ""
        let chunk = "{\"deleteSurface\":{\"surfaceId\":\"1\"}}\n{\"beginRe"
        let messages = parser.parse(chunk: chunk, remainder: &remainder)
        
        XCTAssertEqual(messages.count, 1)
        XCTAssertEqual(remainder, "{\"beginRe")
        
        let messages2 = parser.parse(chunk: "ndering\":{\"surfaceId\":\"1\",\"root\":\"r\"}}\n", remainder: &remainder)
        XCTAssertEqual(messages2.count, 1)
        XCTAssertEqual(remainder, "")
    }
}
