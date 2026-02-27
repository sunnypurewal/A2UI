import Testing
import Foundation
@testable import A2UI

struct A2UIV10Tests {
    private let parser = A2UIParser()

    @Test func parseCreateSurface() throws {
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
        
        let firstMessage = try #require(messages.first)
        guard case .createSurface(let value) = firstMessage else {
            Issue.record("Failed to decode createSurface")
            return
        }
        
        #expect(value.surfaceId == "s1")
        #expect(value.catalogId == "test.catalog")
        #expect(value.theme?["primaryColor"]?.value as? String == "#FF0000")
        #expect(value.sendDataModel == true)
    }

    @Test func parseUpdateComponents() throws {
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
        
        let firstMessage = try #require(messages.first)
        guard case .surfaceUpdate(let update) = firstMessage else {
            Issue.record("Expected surfaceUpdate")
            return
        }
        
        #expect(update.surfaceId == "s1")
        #expect(update.components.count == 1)
        if case .text(let props) = update.components[0].component {
            #expect(props.variant == .h1)
            #expect(props.text.literal == "Hello")
        } else {
            Issue.record("Component is not Text")
        }
    }

    @Test func parseUpdateDataModelWithValue() throws {
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
        
        let firstMessage = try #require(messages.first)
        guard case .dataModelUpdate(let update) = firstMessage else {
            Issue.record("Expected dataModelUpdate")
            return
        }
        
        #expect(update.surfaceId == "s1")
        #expect(update.path == "/user/name")
        #expect(update.value?.value as? String == "John Doe")
    }

    @Test func parseUpdateDataModelWithObjectValue() throws {
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
        
        let firstMessage = try #require(messages.first)
        guard case .dataModelUpdate(let update) = firstMessage else {
            Issue.record("Expected dataModelUpdate")
            return
        }
        
        #expect(update.surfaceId == "s1")
        #expect(update.path == "/user")
        if let valueMap = update.value?.value as? [String: Sendable] {
            #expect(valueMap["firstName"] as? String == "John")
            #expect(valueMap["lastName"] as? String == "Doe")
        } else {
            Issue.record("Expected valueMap for object value")
        }
    }

    @Test func choicePickerParsing() throws {
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
        
        let firstMessage = try #require(messages.first)
        guard case .surfaceUpdate(let update) = firstMessage else {
            Issue.record()
            return
        }
        
        if case .choicePicker(let props) = update.components[0].component {
            #expect(props.options.count == 2)
            #expect(props.variant == .mutuallyExclusive)
        } else {
            Issue.record("Component is not ChoicePicker")
        }
    }

    @Test func parseUserReproWithNulls() throws {
        // This test verifies that 'null' values in 'theme' (AnyCodable) don't crash the parser.
        let json = """
        {"version":"v0.10","createSurface":{"surfaceId":"9EA1C0C3-4FAE-4FD2-BE58-5DD06F4A73F9","catalogId":"https://a2ui.org/specification/v0_10/standard_catalog.json","theme":{"primaryColor":"#F7931A","agentDisplayName":"BTC Tracker","iconUrl":null},"sendDataModel":true}}
        """
        let messages = try parser.parse(line: json)
        #expect(messages.count == 1)
        
        let firstMessage = try #require(messages.first)
        guard case .createSurface(let value) = firstMessage else {
            Issue.record("Failed to decode createSurface")
            return
        }
        
        #expect(value.surfaceId == "9EA1C0C3-4FAE-4FD2-BE58-5DD06F4A73F9")
        #expect(value.theme?["iconUrl"]?.value is JSONNull)
    }

    @Test func parseUserReproFlat() throws {
        let json = """
        {"version":"v0.10","updateComponents":{"surfaceId":"63331743-99E8-44E9-8007-CFF5747F6033","components":[{"id":"card_root","component":"Card","child":"col_main","weight":1},{"id":"col_main","component":"Column","children":["header_text","price_display","meta_row","error_msg","refresh_btn"],"align":"center","justify":"start","weight":1},{"id":"header_text","component":"Text","text":"Bitcoin Price","variant":"h3","weight":0},{"id":"price_display","component":"Text","text":{"path":"/btc/currentPrice"},"variant":"h1","weight":0},{"id":"meta_row","component":"Row","children":["meta_label","meta_time"],"justify":"center","weight":0},{"id":"meta_label","component":"Text","text":"Last updated: ","variant":"caption","weight":0},{"id":"meta_time","component":"Text","text":{"path":"/btc/lastUpdated"},"variant":"caption","weight":0},{"id":"error_msg","component":"Text","text":{"path":"/btc/error"},"variant":"body","weight":0},{"id":"refresh_btn","component":"Button","child":"btn_label","action":{"functionCall":{"call":"refreshBTCPrice","args":{}}},"variant":"primary","weight":0},{"id":"btn_label","component":"Text","text":"Refresh","variant":"body","weight":1}]}}
        """
        let messages = try parser.parse(line: json)
        
        let firstMessage = try #require(messages.first)
        guard case .surfaceUpdate(let update) = firstMessage else {
            Issue.record("Failed to decode surfaceUpdate")
            return
        }
        
        #expect(update.components.count == 10)
        #expect(update.components[0].id == "card_root")
        
        if case .card(let props) = update.components[0].component {
            #expect(props.child == "col_main")
        } else {
            Issue.record("First component should be Card")
        }
    }
}
