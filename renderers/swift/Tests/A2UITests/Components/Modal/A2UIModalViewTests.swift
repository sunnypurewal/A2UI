import Testing
import SwiftUI
import ViewInspector
@testable import A2UI

@MainActor
struct A2UIModalViewTests {
    @Test func modalView() throws {
        let surface = SurfaceState(id: "test")
        let props = ModalProperties(
            trigger: "t1",
            content: "c1"
        )
        
        surface.components["t1"] = ComponentInstance(id: "t1", component: .text(.init(text: .init(literal: "Trigger"), variant: nil)))
        surface.components["c1"] = ComponentInstance(id: "c1", component: .text(.init(text: .init(literal: "Inside Modal"), variant: nil)))
        
        let view = A2UIModalView(properties: props, surface: surface)
            
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let vstack = try view.inspect().find(ViewType.VStack.self)
        #expect(vstack != nil)
        
        let renderer = try vstack.find(A2UIComponentRenderer.self).actualView()
        #expect(renderer.componentId == "t1")
    }
}
