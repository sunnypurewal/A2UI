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
        let deepUpdateJson = "{\"updateDataModel\": {\"surfaceId\": \"s1\", \"path\": \"/user/profile\", \"value\": {\"name\": \"Bob\"}}}"
        store.process(chunk: deepUpdateJson)
        #expect(surface.getValue(at: "user/profile/name") as? String == "Bob")
        
        // Test array update
        let listJson = "{\"updateDataModel\": {\"surfaceId\": \"s1\", \"path\": \"/items\", \"value\": [\"item1\"]}}"
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

    @Test func dataStoreFlush() {
        let partial = "{\"createSurface\":{\"surfaceId\":\"s-flush\",\"catalogId\":\"c1\"}}"
        store.process(chunk: partial) // No newline
        #expect(store.surfaces["s-flush"] != nil)
        
        let beforeFlush = store.surfaces["s-flush"]
        store.flush()
        #expect(store.surfaces["s-flush"] != nil)
        #expect(store.surfaces["s-flush"] === beforeFlush)
    }
}
