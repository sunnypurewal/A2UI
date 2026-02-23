import XCTest
import SwiftUI
@testable import A2UI

@MainActor
final class A2UIExtensibilityTests: XCTestCase {
    var store: A2UIDataStore!

    override func setUp() async throws {
        try await super.setUp()
        store = A2UIDataStore()
    }

    func testCustomComponentDecoding() {
        store.process(chunk: "{\"createSurface\":{\"surfaceId\":\"s1\",\"catalogId\":\"c1\"}}\n")
        let json = "{\"updateComponents\":{\"surfaceId\":\"s1\",\"components\":[{\"id\":\"c1\",\"component\":{\"ChatSurface\":{\"historyPath\":\"/app/history\"}}}]}}"
        
        // Process as chunk (with newline for parser)
        store.process(chunk: json + "\n")
        
        let surface = store.surfaces["s1"]
        XCTAssertNotNil(surface)
        
        let component = surface?.components["c1"]
        XCTAssertNotNil(component)
        
        // Verify it was captured as a custom component
        if case .custom(let name, let properties) = component?.component {
            XCTAssertEqual(name, "ChatSurface")
            XCTAssertEqual(properties["historyPath"]?.value as? String, "/app/history")
        } else {
            XCTFail("Component should have been decoded as .custom")
        }
        
        // Verify helper property
        XCTAssertEqual(component?.component.typeName, "ChatSurface")
    }

    func testCustomRendererRegistry() {
        let expectation = XCTestExpectation(description: "Custom renderer called")
        
        // Register a mock custom renderer
        store.customRenderers["ChatSurface"] = { instance in
            XCTAssertEqual(instance.id, "c1")
            expectation.fulfill()
            return AnyView(Text("Mock Chat"))
        }
        
        // Simulate a message arriving
        store.process(chunk: "{\"createSurface\":{\"surfaceId\":\"s1\",\"catalogId\":\"c1\"}}\n")
        let json = "{\"updateComponents\":{\"surfaceId\":\"s1\",\"components\":[{\"id\":\"c1\",\"component\":{\"ChatSurface\":{\"historyPath\":\"/app/history\"}}}]}}"
        store.process(chunk: json + "\n")
        
        // In a real app, A2UIComponentRenderer would call this.
        // We can verify the lookup manually here.
        let surface = store.surfaces["s1"]!
        let component = surface.components["c1"]!
        
        if let renderer = store.customRenderers[component.component.typeName] {
            let _ = renderer(component)
        } else {
            XCTFail("Custom renderer not found in registry")
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
