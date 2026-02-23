import XCTest
@testable import A2UI

final class A2UIParserTests: XCTestCase {
    var parser: A2UIParser!

    override func setUp() {
        super.setUp()
        parser = A2UIParser()
    }

    // MARK: - Root Message Parsing

    /// Verifies that a `beginRendering` message is correctly decoded with all optional fields.
    func testParseBeginRendering() throws {
        let json = """
        {
            "beginRendering": {
                "surfaceId": "s1",
                "root": "r1",
                "catalogId": "v08",
                "styles": { "primaryColor": "#FF0000" }
            }
        }
        """
        let messages = try parser.parse(line: json)
        if case .createSurface(let value) = messages.first {
            XCTAssertEqual(value.surfaceId, "s1")
            XCTAssertEqual(value.root, "r1")
            XCTAssertEqual(value.catalogId, "v08")
            XCTAssertEqual(value.styles?["primaryColor"]?.value as? String, "#FF0000")
        } else {
            XCTFail("Failed to decode beginRendering")
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
            "surfaceUpdate": {
                "surfaceId": "s1",
                "components": [
                    { "id": "t1", "component": { "Text": { "text": "Hello" } } },
                    { "id": "b1", "component": { "Button": { "child": "t1", "action": { "name": "tap" } } } },
                    { "id": "r1", "component": { "Row": { "children": { "explicitList": ["t1"] } } } },
                    { "id": "c1", "component": { "Column": { "children": { "explicitList": ["b1"] }, "alignment": "center" } } },
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
        
        // Check Row Distribution/Alignment
        if case .row(let props) = update.components[2].component {
            XCTAssertEqual(props.children.explicitList, ["t1"])
        } else { XCTFail("Type mismatch for row") }

        // Check Column Alignment
        if case .column(let props) = update.components[3].component {
            XCTAssertEqual(props.alignment, "center")
        } else { XCTFail("Type mismatch for column") }
    }

    // MARK: - Data Binding & Logic

    /// Verifies that `BoundValue` correctly handles literal strings, literal numbers,
    /// literal booleans, and data model paths.
    func testBoundValueVariants() throws {
        let json = """
        {
            "surfaceUpdate": {
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

    /// Verifies that dynamic data updates handle nested maps and different value types correctly.
    func testDataModelUpdateComplexity() throws {
        let json = """
        {
            "dataModelUpdate": {
                "surfaceId": "s1",
                "contents": [
                    { "key": "k1", "valueString": "v1" },
                    { "key": "k2", "valueNumber": 123.45 },
                    { "key": "k3", "valueBoolean": true },
                    { "key": "k4", "valueMap": {
                        "sub": { "key": "sub", "valueString": "nested" }
                    }}
                ]
            }
        }
        """
        let messages = try parser.parse(line: json)
        guard case .dataModelUpdate(let update) = messages.first else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(update.contents.count, 4)
        XCTAssertEqual(update.contents[1].valueNumber, 123.45)
        XCTAssertEqual(update.contents[3].valueMap?["sub"]?.valueString, "nested")
    }

    func testDataModelUpdateContentsDictionary() throws {
        let json = """
        {
            "dataModelUpdate": {
                "surfaceId": "s1",
                "contents": {
                    "str": "value",
                    "num": 42,
                    "nested": { "foo": "bar" },
                    "list": ["a", "b"]
                }
            }
        }
        """
        let messages = try parser.parse(line: json)
        guard case .dataModelUpdate(let update) = messages.first else {
            XCTFail("Expected dataModelUpdate")
            return
        }

        XCTAssertTrue(update.contents.contains { $0.key == "str" && $0.valueString == "value" })
        XCTAssertTrue(update.contents.contains { $0.key == "num" && $0.valueNumber == 42 })

        if let nested = update.contents.first(where: { $0.key == "nested" })?.valueMap {
            XCTAssertEqual(nested["foo"]?.valueString, "bar")
        } else {
            XCTFail("Nested map entry missing")
        }

        if let listEntry = update.contents.first(where: { $0.key == "list" })?.valueList {
            XCTAssertEqual(listEntry[0].valueString, "a")
            XCTAssertEqual(listEntry[1].valueString, "b")
        } else {
            XCTFail("List entry missing")
        }
    }

    // MARK: - Error Handling & Edge Cases

    /// Verifies that the parser decodes unknown component types as .custom instead of throwing.
    func testParseUnknownComponent() throws {
        let json = "{\"surfaceUpdate\": {\"surfaceId\": \"s1\", \"components\": [{\"id\": \"1\", \"component\": {\"Unknown\": {\"foo\":\"bar\"}}}]}}"
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
        {"dataModelUpdate":{"surfaceId":"s1","contents":[]}},{"surfaceUpdate":{"surfaceId":"s1","components":[]}}
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
        let action = Action.createCustom(name: "testAction")
        let boundStr = BoundValue<String>(literal: "test")
        let boundBool = BoundValue<Bool>(literal: true)
        let boundNum = BoundValue<Double>(literal: 42)
        let children = Children(explicitList: ["c1"])

        let components: [ComponentType] = [
            .text(.init(text: boundStr, usageHint: "H")),
            .button(.init(label: boundStr, child: "C", action: action, primary: true)),
            .row(.init(children: children, distribution: "fill", alignment: "center")),
            .column(.init(children: children, distribution: "start", alignment: "leading")),
            .card(.init(child: "C")),
            .image(.init(url: boundStr, altText: boundStr, width: 100, height: 100)),
            .icon(.init(name: boundStr, size: 24, color: "#FF0000")),
            .video(.init(url: boundStr, autoPlay: true, loop: true)),
            .audioPlayer(.init(url: boundStr, autoPlay: false, loop: false)),
            .divider(.init()),
            .list(.init(children: children, scrollable: true)),
            .tabs(.init(tabItems: [TabItem(title: boundStr, child: "c1")])),
            .modal(.init(entryPointChild: "e1", contentChild: "c1", isOpen: boundBool)),
            .textField(.init(label: boundStr, value: boundStr, placeholder: boundStr, type: "email", action: action)),
            .checkBox(.init(label: boundStr, value: boundBool, action: action)),
            .dateTimeInput(.init(label: boundStr, value: boundStr, type: "date", action: action)),
            .multipleChoice(.init(label: boundStr, selections: [SelectionOption(label: boundStr, value: "v1", isSelected: boundBool)], type: "radio", action: action)),
            .slider(.init(label: boundStr, value: boundNum, min: 0, max: 100, step: 1, action: action)),
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
