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
        store.process(chunk: "{\"createSurface\":{\"surfaceId\":\"s1\",\"catalogId\":\"c1\"}}\n")
        XCTAssertNotNil(store.surfaces["s1"])
        
        let existingSurface = store.surfaces["s1"]
        store.process(chunk: "{\"updateComponents\":{\"surfaceId\":\"s1\",\"components\":[]}}\n")
        XCTAssertIdentical(store.surfaces["s1"], existingSurface)
    }

    func testSurfaceDeletion() {
        store.process(chunk: "{\"createSurface\":{\"surfaceId\":\"s1\",\"catalogId\":\"c1\"}}\n")
        XCTAssertNotNil(store.surfaces["s1"])
        
        store.process(chunk: "{\"deleteSurface\":{\"surfaceId\":\"s1\"}}\n")
        XCTAssertNil(store.surfaces["s1"])
    }

    // MARK: - Message Processing

    func testSurfaceUpdateProcessing() {
        let json = "{\"updateComponents\": {\"surfaceId\": \"s1\", \"components\": [{\"id\": \"c1\", \"component\": {\"Text\": {\"text\": \"Hello\"}}}]}}\n"
        store.process(chunk: json)
        
        let surface = store.surfaces["s1"]
        XCTAssertEqual(surface?.components.count, 1)
        XCTAssertNotNil(surface?.components["c1"])
    }

    func testDataModelUpdateMerging() {
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
        XCTAssertEqual(model?["name"] as? String, "Alice")
        XCTAssertEqual(model?["age"] as? Double, 30)
        XCTAssertEqual(model?["isMember"] as? Bool, true)
        
        // Test deep update
        let deepUpdateJson = "{\"updateDataModel\": {\"surfaceId\": \"s1\", \"path\": \"/user/profile\", \"value\": {\"name\": \"Bob\"}}}"
        store.process(chunk: deepUpdateJson)
        XCTAssertEqual(surface.getValue(at: "user/profile/name") as? String, "Bob")
        
        // Test array update
        let listJson = "{\"updateDataModel\": {\"surfaceId\": \"s1\", \"path\": \"/items\", \"value\": [\"item1\"]}}"
        store.process(chunk: listJson)
        XCTAssertEqual(surface.getValue(at: "items/0") as? String, "item1")
    }

    func testUserActionTrigger() {
        let surface = SurfaceState(id: "s1")
        let expectation = XCTestExpectation(description: "Action triggered")
        
        surface.actionHandler = { userAction in
            if case .custom(let name, _) = userAction.action {
                XCTAssertEqual(name, "submit")
            } else {
                XCTFail("Incorrect action type")
            }
            expectation.fulfill()
        }
        
        surface.trigger(action: Action.custom(name: "submit", context: nil))
        wait(for: [expectation], timeout: 1.0)
    }

    func testDataStoreProcessChunkWithSplitMessages() {
        let chunk1 = "{\"deleteSurface\":{\"surfaceId\":\"s1\"}}\n{\"createSurface"
        let chunk2 = "\":{\"surfaceId\":\"s2\",\"catalogId\":\"c1\"}}\n"
        
        store.process(chunk: chunk1)
        XCTAssertNil(store.surfaces["s2"]) // Partial message
        
        store.process(chunk: chunk2)
        XCTAssertNotNil(store.surfaces["s2"])
    }

    func testDataStoreFlush() {
        let partial = "{\"createSurface\":{\"surfaceId\":\"s-flush\",\"catalogId\":\"c1\"}}"
        store.process(chunk: partial) // No newline
        XCTAssertNil(store.surfaces["s-flush"])
        
        store.flush()
        XCTAssertNotNil(store.surfaces["s-flush"])
    }
}
