import Testing
import SwiftUI
@testable import A2UI

@MainActor
struct A2UIExtensibilityTests {
    private let store = A2UIDataStore()

    @Test func customComponentDecoding() {
        store.process(chunk: "{\"createSurface\":{\"surfaceId\":\"s1\",\"catalogId\":\"c1\"}}\n")
        let json = "{\"updateComponents\":{\"surfaceId\":\"s1\",\"components\":[{\"id\":\"c1\",\"component\":{\"ChatSurface\":{\"historyPath\":\"/app/history\"}}}]}}"
        
        // Process as chunk (with newline for parser)
        store.process(chunk: json + "\n")
        
        let surface = store.surfaces["s1"]
        #expect(surface != nil)
        
        let component = surface?.components["c1"]
        #expect(component != nil)
        
        // Verify it was captured as a custom component
        if case .custom(let name, let properties) = component?.component {
            #expect(name == "ChatSurface")
            #expect(properties["historyPath"]?.value as? String == "/app/history")
        } else {
            Issue.record("Component should have been decoded as .custom")
        }
        
        // Verify helper property
        #expect(component?.component.typeName == "ChatSurface")
    }

    @Test func customRendererRegistry() async {
        await confirmation("Custom renderer called") { confirmed in
            // Register a mock custom renderer
            store.customRenderers["ChatSurface"] = { instance in
                #expect(instance.id == "c1")
                confirmed()
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
                Issue.record("Custom renderer not found in registry")
            }
        }
    }
}
