import XCTest
@testable import A2UI

@MainActor
final class A2UIDataStoreTests: XCTestCase {
    var store: A2UIDataStore!

    override func setUp() async throws {
        try await super.setUp()
        store = A2UIDataStore()
    }

    // MARK: - Surface Lifecycle

    func testSurfaceCreationAndRetrieval() {
        store.process(chunk: "{\"beginRendering\":{\"surfaceId\":\"s1\",\"root\":\"r1\"}}\n")
        XCTAssertNotNil(store.surfaces["s1"])
        XCTAssertTrue(store.surfaces["s1"]?.isReady ?? false)
        
        let existingSurface = store.surfaces["s1"]
        store.process(chunk: "{\"surfaceUpdate\":{\"surfaceId\":\"s1\",\"components\":[]}}\n")
        XCTAssertIdentical(store.surfaces["s1"], existingSurface)
    }

    func testSurfaceDeletion() {
        store.process(chunk: "{\"beginRendering\":{\"surfaceId\":\"s1\",\"root\":\"r1\"}}\n")
        XCTAssertNotNil(store.surfaces["s1"])
        
        store.process(chunk: "{\"deleteSurface\":{\"surfaceId\":\"s1\"}}\n")
        XCTAssertNil(store.surfaces["s1"])
    }

    // MARK: - Message Processing

    func testSurfaceUpdateProcessing() {
        let json = "{\"surfaceUpdate\": {\"surfaceId\": \"s1\", \"components\": [{\"id\": \"c1\", \"component\": {\"Text\": {\"text\": {\"literalString\": \"Hello\"}}}}]}}\n"
        store.process(chunk: json)
        
        let surface = store.surfaces["s1"]
        XCTAssertEqual(surface?.components.count, 1)
        XCTAssertNotNil(surface?.components["c1"])
    }

    func testDataModelUpdateMerging() {
        let json = "{\"dataModelUpdate\": {\"surfaceId\": \"s1\", \"contents\": [{\"key\": \"name\", \"valueString\": \"Alice\"},{\"key\": \"age\", \"valueNumber\": 30},{\"key\": \"isMember\", \"valueBoolean\": true}]}}\n"
        store.process(chunk: json)
        
        let model = store.surfaces["s1"]?.dataModel
        XCTAssertEqual(model?["name"] as? String, "Alice")
        XCTAssertEqual(model?["age"] as? Double, 30)
        XCTAssertEqual(model?["isMember"] as? Bool, true)
    }
    
    func testDeepDataModelUpdate() {
        store.process(chunk: "{\"beginRendering\":{\"surfaceId\":\"s1\",\"root\":\"r1\"}}\n")
        let surface = store.surfaces["s1"]!
        
        // Simple nesting (Single-line JSON!)
        let json = "{\"dataModelUpdate\": {\"surfaceId\": \"s1\", \"contents\": [{\"key\": \"user\", \"valueMap\": {\"name\": {\"key\": \"name\", \"valueString\": \"Bob\"}}}]}}\n"
        store.process(chunk: json)
        XCTAssertEqual(surface.getValue(at: "user/name") as? String, "Bob")
        
        // Array (Single-line JSON!)
        let listJson = "{\"dataModelUpdate\": {\"surfaceId\": \"s1\", \"contents\": [{\"key\": \"items\", \"valueList\": [{\"key\": \"0\", \"valueString\": \"item1\"}]}]}}\n"
        store.process(chunk: listJson)
        XCTAssertEqual(surface.getValue(at: "items/0") as? String, "item1")
    }

    func testPathResolution() {
        let surface = SurfaceState(id: "s1")
        surface.dataModel = [
            "user": [
                "profile": [
                    "name": "Charlie",
                    "scores": [10, 20, 30]
                ]
            ]
        ]
        
        XCTAssertEqual(surface.getValue(at: "user/profile/name") as? String, "Charlie")
        XCTAssertEqual(surface.getValue(at: "user/profile/scores/1") as? Int, 20)
    }

    func testTemplateExpansion() {
        let surface = SurfaceState(id: "s1")
        surface.dataModel = [
            "items": ["a", "b", "c"]
        ]
        
        let template = Template(componentId: "row-item", dataBinding: "items")
        let ids = surface.expandTemplate(template: template)
        
        XCTAssertEqual(ids.count, 3)
        XCTAssertEqual(ids[0], "row-item:items:0")
    }

    func testUserActionTrigger() {
        let surface = SurfaceState(id: "s1")
        let expectation = XCTestExpectation(description: "Action triggered")
        
        surface.actionHandler = { action in
            XCTAssertEqual(action.action.name, "submit")
            expectation.fulfill()
        }
        
        surface.trigger(action: Action.createCustom(name: "submit", context: nil))
        wait(for: [expectation], timeout: 1.0)
    }

    func testLegacyDataFieldDecoding() throws {
        let json = "{\"dataModelUpdate\":{\"surfaceId\":\"s1\",\"data\":{\"str\":\"val\",\"num\":123,\"bool\":true,\"nested\":{\"key\":\"val\"},\"list\":[\"a\",1]}}}"
        let data = json.data(using: .utf8)!
        let message = try JSONDecoder().decode(A2UIMessage.self, from: data)
        
        if case .dataModelUpdate(let update) = message {
            XCTAssertEqual(update.surfaceId, "s1")
            // Note: DataModelUpdate decoding converts to contents
            XCTAssertTrue(update.contents.contains { $0.key == "str" && $0.valueString == "val" })
            XCTAssertTrue(update.contents.contains { $0.key == "num" && $0.valueNumber == 123 })
            XCTAssertTrue(update.contents.contains { $0.key == "bool" && $0.valueBoolean == true })
        } else {
            XCTFail()
        }
    }

    func testDataStoreProcessChunkWithSplitMessages() {
        let chunk1 = "{\"deleteSurface\":{\"surfaceId\":\"s1\"}}\n{\"beginRe"
        let chunk2 = "ndering\":{\"surfaceId\":\"s2\",\"root\":\"r1\"}}\n"
        
        store.process(chunk: chunk1)
        XCTAssertNil(store.surfaces["s2"]) // Partial message
        
        store.process(chunk: chunk2)
        XCTAssertNotNil(store.surfaces["s2"])
        XCTAssertTrue(store.surfaces["s2"]?.isReady ?? false)
    }

    func testDataStoreFlush() {
        let partial = "{\"beginRendering\":{\"surfaceId\":\"s-flush\",\"root\":\"r\"}}"
        store.process(chunk: partial) // No newline
        XCTAssertNil(store.surfaces["s-flush"])
        
        store.flush()
        XCTAssertNotNil(store.surfaces["s-flush"])
    }
}
