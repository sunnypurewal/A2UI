import Testing
import Foundation
@testable import A2UI

@MainActor
struct A2UIDataStoreTests {
    private let store = A2UIDataStore()

    // MARK: - Surface Lifecycle

    @Test func surfaceCreationAndRetrieval() {
        store.process(chunk: "{\"createSurface\":{\"surfaceId\":\"s1\",\"catalogId\":\"c1\"}}\n")
        #expect(store.surfaces["s1"] != nil)
        
        let existingSurface = store.surfaces["s1"]
        store.process(chunk: "{\"updateComponents\":{\"surfaceId\":\"s1\",\"components\":[]}}\n")
        #expect(store.surfaces["s1"] === existingSurface)
    }

    @Test func surfaceDeletion() {
        store.process(chunk: "{\"createSurface\":{\"surfaceId\":\"s1\",\"catalogId\":\"c1\"}}\n")
        #expect(store.surfaces["s1"] != nil)
        
        store.process(chunk: "{\"deleteSurface\":{\"surfaceId\":\"s1\"}}\n")
        #expect(store.surfaces["s1"] == nil)
    }

    // MARK: - Message Processing

    @Test func surfaceUpdateProcessing() {
        let json = "{\"updateComponents\": {\"surfaceId\": \"s1\", \"components\": [{\"id\": \"c1\", \"component\": {\"Text\": {\"text\": \"Hello\"}}}]}}\n"
        store.process(chunk: json)
        
        let surface = store.surfaces["s1"]
        #expect(surface?.components.count == 1)
        #expect(surface?.components["c1"] != nil)
    }

    @Test func dataModelUpdateMerging() {
        let surface = SurfaceState(id: "s1")
        surface.dataModel = [
            "name": "initial",
            "user": [ "profile": [:] ],
            "items": []
        ]
        store.surfaces["s1"] = surface
        
        let json = "{\"updateDataModel\": {\"surfaceId\": \"s1\", \"value\": {\"name\":\"Alice\",\"age\":30,\"isMember\":true}}}\n"
        store.process(chunk: json)
        
        let model = store.surfaces["s1"]?.dataModel
        #expect(model?["name"] as? String == "Alice")
        #expect(model?["age"] as? Double == 30)
        #expect(model?["isMember"] as? Bool == true)
        
        // Test deep update
        let deepUpdateJson = "{\"updateDataModel\": {\"surfaceId\": \"s1\", \"path\": \"/user/profile\", \"value\": {\"name\": \"Bob\"}}}\n"
        store.process(chunk: deepUpdateJson)
        #expect(surface.getValue(at: "user/profile/name") as? String == "Bob")
        
        // Test array update
        let listJson = "{\"updateDataModel\": {\"surfaceId\": \"s1\", \"path\": \"/items\", \"value\": [\"item1\"]}}\n"
        store.process(chunk: listJson)
        #expect(surface.getValue(at: "items/0") as? String == "item1")
    }

    @Test func userActionTrigger() async {
        let surface = SurfaceState(id: "s1")
        
        await confirmation("Action triggered") { confirmed in
            surface.actionHandler = { userAction in
                if case .custom(let name, _) = userAction.action {
                    #expect(name == "submit")
                } else {
                    Issue.record("Incorrect action type")
                }
                confirmed()
            }
            
            surface.trigger(action: Action.custom(name: "submit", context: nil))
        }
    }

    @Test func dataStoreProcessChunkWithSplitMessages() {
        var chunk = "{\"deleteSurface\":{\"surfaceId\":\"s1\"}}\n{\"createSurface"
        store.process(chunk: chunk)
        #expect(store.surfaces["s2"] == nil) // Partial message
        
        chunk = "\":{\"surfaceId\":\"s2\",\"catalogId\":\"c1\"}}\n"
        store.process(chunk: chunk)
        #expect(store.surfaces["s2"] != nil)
    }

    @Test func dataStoreFlushWithCreate() {
        let surfaceId = "flush_create"
        let chunk = "{\"createSurface\":{\"surfaceId\":\"\(surfaceId)\",\"catalogId\":\"c1\"}}"
        
        store.process(chunk: chunk)
        #expect(store.surfaces[surfaceId] == nil)
        
        store.flush()
        #expect(store.surfaces[surfaceId] != nil)
    }

    @Test func dataStoreFlushWithDelete() {
        let surfaceId = "flush_delete"
        // First create it
        store.process(chunk: "{\"createSurface\":{\"surfaceId\":\"\(surfaceId)\",\"catalogId\":\"c1\"}}\n")
        #expect(store.surfaces[surfaceId] != nil)
        
        // Then send a partial delete
        let chunk = "{\"deleteSurface\":{\"surfaceId\":\"\(surfaceId)\"}}"
        store.process(chunk: chunk)
        #expect(store.surfaces[surfaceId] != nil) // Still there
        
        store.flush()
        #expect(store.surfaces[surfaceId] == nil) // Now deleted
    }

    @Test func fallbackRootComponent() {
        let json = "{\"updateComponents\": {\"surfaceId\": \"s1\", \"components\": [{\"id\": \"c1\", \"component\": {\"Text\": {\"text\": \"Hello\"}}}]}}\n"
        store.process(chunk: json)
        #expect(store.surfaces["s1"]?.rootComponentId == "c1")
    }

    @Test func explicitRootComponent() {
        let json = "{\"updateComponents\": {\"surfaceId\": \"s1\", \"components\": [{\"id\": \"c1\", \"component\": {\"Text\": {\"text\": \"Hello\"}}}, {\"id\": \"root\", \"component\": {\"Row\": {\"children\": [\"c1\"]}}}]}}\n"
        store.process(chunk: json)
        #expect(store.surfaces["s1"]?.rootComponentId == "root")
    }

    @Test func appMessageProcessing() async {
        await confirmation("App message handled") { confirmed in
            store.appMessageHandler = { name, data in
                #expect(name == "my_event")
                let payload = data[name]?.value as? [String: Any]
                #expect(payload?["foo"] as? String == "bar")
                confirmed()
            }
            let json = "{\"my_event\": {\"foo\": \"bar\"}}\n"
            store.process(chunk: json)
        }
    }

    @Test func textMessageProcessing() async {
        await confirmation("Text message received") { confirmed in
            store.onTextMessageReceived = { text in
                #expect(text == "hello world")
                confirmed()
            }
            // store.process(chunk: "{\"text\": \"hello world\"}\n")
            // Wait, I need a valid app message name and a string payload.
            let json = "{\"text\": \"hello world\"}\n"
            store.process(chunk: json)
        }
    }

    @Test func dataUpdateActionHandling() {
        let surfaceId = "s1"
        store.process(chunk: "{\"createSurface\":{\"surfaceId\":\"\(surfaceId)\",\"catalogId\":\"c1\"}}\n")
        let surface = store.surfaces[surfaceId]!
        
        surface.trigger(action: .dataUpdate(DataUpdateAction(path: "val", contents: AnyCodable("new"))))
        #expect(surface.dataModel["val"] as? String == "new")
    }

    @Test func functionCallActionHandling() {
        let surfaceId = "s1"
        store.process(chunk: "{\"createSurface\":{\"surfaceId\":\"\(surfaceId)\",\"catalogId\":\"c1\"}}\n")
        let surface = store.surfaces[surfaceId]!
        
        // Use a function call that might be handled.
        // Even if it doesn't do much, it should exercise the code path.
        let call = FunctionCall(call: "formatString", args: ["template": AnyCodable("test")])
        surface.trigger(action: .functionCall(call))
    }

    // MARK: - SurfaceState Deep Dive

    @Test func surfaceStateResolve() {
        let surface = SurfaceState(id: "s1")
        surface.dataModel = [
            "str": "hello",
            "int": 42,
            "double": 3.14,
            "bool": true,
            "null": NSNull(),
            "nested": ["key": "val"]
        ]
        
        // Literal
        #expect(surface.resolve(BoundValue<String>(literal: "lit")) == "lit")
        
        // Path resolution and conversion
        #expect(surface.resolve(BoundValue<String>(path: "str")) == "hello")
        #expect(surface.resolve(BoundValue<String>(path: "int")) == "42")
        #expect(surface.resolve(BoundValue<String>(path: "double")) == "3.14")
        #expect(surface.resolve(BoundValue<String>(path: "bool")) == "true")
        
        #expect(surface.resolve(BoundValue<Int>(path: "int")) == 42)
        #expect(surface.resolve(BoundValue<Double>(path: "int")) == 42.0)
        #expect(surface.resolve(BoundValue<Int>(path: "double")) == 3)
        #expect(surface.resolve(BoundValue<Double>(path: "double")) == 3.14)
        
        #expect(surface.resolve(BoundValue<String>(path: "null")) == nil)
        #expect(surface.resolve(BoundValue<String>(path: "missing")) == nil)
        
        // Function Call (minimal test here, A2UIFunctionTests covers more)
        let call = FunctionCall(call: "pluralize", args: ["value": AnyCodable(1), "one": AnyCodable("1 apple"), "other": AnyCodable("apples")])
        #expect(surface.resolve(BoundValue<String>(functionCall: call)) == "1 apple")
    }

    @Test func surfaceStateRunChecks() {
        let surface = SurfaceState(id: "s1")
        let check = CheckRule(condition: BoundValue<Bool>(path: "isValid"), message: "Invalid Value")
        surface.components["c1"] = ComponentInstance(id: "c1", checks: [check], component: .text(.init(text: .init(literal: ""), variant: nil)))
        
        surface.dataModel["isValid"] = false
        surface.runChecks(for: "c1")
        #expect(surface.validationErrors["c1"] == "Invalid Value")
        
        surface.dataModel["isValid"] = true
        surface.runChecks(for: "c1")
        #expect(surface.validationErrors["c1"] == nil)
        
        surface.runChecks(for: "missing") // Should not crash
    }

    @Test func surfaceStateExpandTemplate() {
        let surface = SurfaceState(id: "s1")
        surface.dataModel["items"] = ["a", "b", "c"]
        
        let template = Template(componentId: "row", path: "items")
        let ids = surface.expandTemplate(template: template)
        #expect(ids.count == 3)
        #expect(ids[0] == "row:items:0")
        
        #expect(surface.expandTemplate(template: Template(componentId: "row", path: "missing")).isEmpty)
    }
}
