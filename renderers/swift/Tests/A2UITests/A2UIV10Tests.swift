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
                        "component": "Text",
                        "text": "Hello",
                        "variant": "h1"
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
            XCTAssertEqual(props.variant, .h1)
            XCTAssertEqual(props.text.literal, "Hello")
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
        XCTAssertEqual(update.value?.value as? String, "John Doe")
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
        if let valueMap = update.value?.value as? [String: Sendable] {
            XCTAssertEqual(valueMap["firstName"] as? String, "John")
            XCTAssertEqual(valueMap["lastName"] as? String, "Doe")
        } else {
            XCTFail("Expected valueMap for object value")
        }
    }

    func testChoicePickerParsing() throws {
        let json = """
        {
            "version": "v0.10",
            "updateComponents": {
                "surfaceId": "s1",
                "components": [
                    { 
                        "id": "cp1", 
                        "component": "ChoicePicker",
                        "label": "Pick one",
                        "options": [
                            { "label": "Option 1", "value": "1" },
                            { "label": "Option 2", "value": "2" }
                        ],
                        "variant": "mutuallyExclusive",
                        "value": ["1"]
                    }
                ]
            }
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

    func testParseUserReproWithNulls() throws {
        // This test verifies that 'null' values in 'theme' (AnyCodable) don't crash the parser.
        let json = """
        {"version":"v0.10","createSurface":{"surfaceId":"9EA1C0C3-4FAE-4FD2-BE58-5DD06F4A73F9","catalogId":"https://a2ui.org/specification/v0_10/standard_catalog.json","theme":{"primaryColor":"#F7931A","agentDisplayName":"BTC Tracker","iconUrl":null},"sendDataModel":true}}
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

    func testParseUserReproFlat() throws {
        let json = """
        {"version":"v0.10","updateComponents":{"surfaceId":"63331743-99E8-44E9-8007-CFF5747F6033","components":[{"id":"card_root","component":"Card","child":"col_main","weight":1},{"id":"col_main","component":"Column","children":["header_text","price_display","meta_row","error_msg","refresh_btn"],"align":"center","justify":"start","weight":1},{"id":"header_text","component":"Text","text":"Bitcoin Price","variant":"h3","weight":0},{"id":"price_display","component":"Text","text":{"path":"/btc/currentPrice"},"variant":"h1","weight":0},{"id":"meta_row","component":"Row","children":["meta_label","meta_time"],"justify":"center","weight":0},{"id":"meta_label","component":"Text","text":"Last updated: ","variant":"caption","weight":0},{"id":"meta_time","component":"Text","text":{"path":"/btc/lastUpdated"},"variant":"caption","weight":0},{"id":"error_msg","component":"Text","text":{"path":"/btc/error"},"variant":"body","weight":0},{"id":"refresh_btn","component":"Button","child":"btn_label","action":{"functionCall":{"call":"refreshBTCPrice","args":{}}},"variant":"primary","weight":0},{"id":"btn_label","component":"Text","text":"Refresh","variant":"body","weight":1}]}}
        """
        let messages = try parser.parse(line: json)
        guard case .surfaceUpdate(let update) = messages.first else {
            XCTFail("Failed to decode surfaceUpdate")
            return
        }
        XCTAssertEqual(update.components.count, 10)
        XCTAssertEqual(update.components[0].id, "card_root")
        if case .card(let props) = update.components[0].component {
            XCTAssertEqual(props.child, "col_main")
        } else {
            XCTFail("First component should be Card")
        }
    }
}
