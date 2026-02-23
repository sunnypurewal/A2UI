import XCTest
@testable import A2UI

final class A2UIV10Tests: XCTestCase {
    var parser: A2UIParser!

    override func setUp() {
        super.setUp()
        parser = A2UIParser()
    }

    func testParseCreateSurface() throws {
        let json = """
        {
            "version": "v0.10",
            "createSurface": {
                "surfaceId": "s1",
                "catalogId": "test.catalog",
                "theme": { "primaryColor": "#FF0000" },
                "sendDataModel": true
            }
        }
        """
        let messages = try parser.parse(line: json)
        guard case .createSurface(let value) = messages.first else {
            XCTFail("Failed to decode createSurface")
            return
        }
        XCTAssertEqual(value.surfaceId, "s1")
        XCTAssertEqual(value.catalogId, "test.catalog")
        XCTAssertEqual(value.theme?["primaryColor"]?.value as? String, "#FF0000")
        XCTAssertEqual(value.sendDataModel, true)
        XCTAssertNil(value.root)
    }

    func testParseUpdateComponents() throws {
        let json = """
        {
            "version": "v0.10",
            "updateComponents": {
                "surfaceId": "s1",
                "components": [
                    {
                        "id": "root",
                        "component": {
                            "Text": {
                                "text": "Hello",
                                "variant": "h1"
                            }
                        }
                    }
                ]
            }
        }
        """
        let messages = try parser.parse(line: json)
        guard case .surfaceUpdate(let update) = messages.first else {
            XCTFail("Expected surfaceUpdate")
            return
        }
        XCTAssertEqual(update.surfaceId, "s1")
        XCTAssertEqual(update.components.count, 1)
        if case .text(let props) = update.components[0].component {
            XCTAssertEqual(props.variant, "h1")
        } else {
            XCTFail("Component is not Text")
        }
    }

    func testParseUpdateDataModelWithValue() throws {
        let json = """
        {
            "version": "v0.10",
            "updateDataModel": {
                "surfaceId": "s1",
                "path": "/user/name",
                "value": "John Doe"
            }
        }
        """
        let messages = try parser.parse(line: json)
        guard case .dataModelUpdate(let update) = messages.first else {
            XCTFail("Expected dataModelUpdate")
            return
        }
        XCTAssertEqual(update.surfaceId, "s1")
        XCTAssertEqual(update.path, "/user/name")
        XCTAssertEqual(update.value.value as? String, "John Doe")
    }

    func testParseUpdateDataModelWithObjectValue() throws {
        let json = """
        {
            "version": "v0.10",
            "updateDataModel": {
                "surfaceId": "s1",
                "path": "/user",
                "value": { "firstName": "John", "lastName": "Doe" }
            }
        }
        """
        let messages = try parser.parse(line: json)
        guard case .dataModelUpdate(let update) = messages.first else {
            XCTFail("Expected dataModelUpdate")
            return
        }
        XCTAssertEqual(update.surfaceId, "s1")
        XCTAssertEqual(update.path, "/user")
        if let valueMap = update.value.value as? [String: Sendable] {
            XCTAssertEqual(valueMap["firstName"] as? String, "John")
            XCTAssertEqual(valueMap["lastName"] as? String, "Doe")
        } else {
            XCTFail("Expected valueMap for object value")
        }
    }

    func testChoicePickerParsing() throws {
        let json = """
        {
            "updateComponents": {
                "surfaceId": "s1",
                "components": [
                    { 
                        "id": "cp1", 
                        "component": { 
                            "ChoicePicker": { 
                                "label": "Pick one",
                                "options": [
                                    { "label": "Option 1", "value": "1" },
                                    { "label": "Option 2", "value": "2" }
                                ],
                                "variant": "mutuallyExclusive",
                                "value": ["1"]
                            }
                        }
                    }
                ]
            },
            "version": "v0.10"
        }
        """
        // Note: BoundValue<[String]> needs to handle array literal
        let messages = try parser.parse(line: json)
        guard case .surfaceUpdate(let update) = messages.first else {
            XCTFail()
            return
        }
        if case .choicePicker(let props) = update.components[0].component {
            XCTAssertEqual(props.options.count, 2)
            XCTAssertEqual(props.variant, "mutuallyExclusive")
        } else {
            XCTFail("Component is not ChoicePicker")
        }
    }

    func testParseTypePropertyStyle() throws {
        let json = """
        {
            "version": "v0.10",
            "type": "createSurface",
            "surfaceId": "8E69A01C-B7F2-47C4-8A1E-245C46162FFF",
            "catalogId": "https://a2ui.org/specification/v0_10/standard_catalog.json"
        }
        """
        let messages = try parser.parse(line: json)
        guard case .createSurface(let value) = messages.first else {
            XCTFail("Failed to decode type-property style createSurface")
            return
        }
        XCTAssertEqual(value.surfaceId, "8E69A01C-B7F2-47C4-8A1E-245C46162FFF")
        XCTAssertEqual(value.catalogId, "https://a2ui.org/specification/v0_10/standard_catalog.json")
    }

    func testParseFloatingDiscriminator() throws {
        // Test case where the discriminator is in a field named "action" instead of "type" or being a key
        let json1 = """
        {
            "action": "createSurface",
            "surfaceId": "A4867E6E-994F-4188-ADD1-6BDB839E34BE",
            "name": "Bitcoin Price Tracker"
        }
        """
        let messages1 = try parser.parse(line: json1)
        guard case .createSurface(let value1) = messages1.first else {
            XCTFail("Failed to decode action-property style createSurface")
            return
        }
        XCTAssertEqual(value1.name, "Bitcoin Price Tracker")
        
        // Test case where the discriminator is in a random field named "vibe"
        let json2 = """
        {
            "vibe": "updateDataModel",
            "surfaceId": "s1",
            "path": "/price",
            "value": 50000
        }
        """
        let messages2 = try parser.parse(line: json2)
        guard case .dataModelUpdate(let update2) = messages2.first else {
            XCTFail("Failed to decode floating-discriminator style dataModelUpdate")
            return
        }
        XCTAssertEqual(update2.path, "/price")
        
        // Test case where the discriminator is updateComponents in a field named "method"
        let json3 = """
        {
            "method": "updateComponents",
            "surfaceId": "s1",
            "updateComponents": [
                {
                    "id": "root",
                    "component": { "Text": { "text": "New UI" } }
                }
            ]
        }
        """
        let messages3 = try parser.parse(line: json3)
        guard case .surfaceUpdate(let update3) = messages3.first else {
            XCTFail("Failed to decode floating-discriminator style surfaceUpdate")
            return
        }
        XCTAssertEqual(update3.components.count, 1)
    }

    func testParseDeleteSurfaceRobustness() throws {
        // v0.8 style
        let json1 = """
        {
            "deleteSurface": true,
            "surfaceId": "s1"
        }
        """
        let messages1 = try parser.parse(line: json1)
        guard case .deleteSurface(let del1) = messages1.first else {
            XCTFail()
            return
        }
        XCTAssertEqual(del1.surfaceId, "s1")
        
        // Floating action style
        let json2 = """
        {
            "op": "deleteSurface",
            "surfaceId": "s2"
        }
        """
        let messages2 = try parser.parse(line: json2)
        guard case .deleteSurface(let del2) = messages2.first else {
            XCTFail()
            return
        }
        XCTAssertEqual(del2.surfaceId, "s2")
    }

    func testParseUserReproWithNulls() throws {
        // This test verifies that 'null' values in 'theme' (AnyCodable) don't crash the parser.
        let json = """
        {"version":"v0.10","createSurface":{"surfaceId":"9EA1C0C3-4FAE-4FD2-BE58-5DD06F4A73F9","root":"root_card","catalogId":"https://a2ui.org/specification/v0_10/standard_catalog.json","theme":{"primaryColor":"#F7931A","agentDisplayName":"BTC Tracker","iconUrl":null},"sendDataModel":true}}
        """
        let messages = try parser.parse(line: json)
        XCTAssertEqual(messages.count, 1)
        guard case .createSurface(let value) = messages.first else {
            XCTFail("Failed to decode createSurface")
            return
        }
        XCTAssertEqual(value.surfaceId, "9EA1C0C3-4FAE-4FD2-BE58-5DD06F4A73F9")
        XCTAssertTrue(value.theme?["iconUrl"]?.value is JSONNull)
    }
}
