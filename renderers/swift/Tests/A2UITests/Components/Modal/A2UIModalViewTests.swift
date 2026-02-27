import XCTest
import SwiftUI
import ViewInspector
@testable import A2UI

final class A2UIModalViewTests: XCTestCase {
    @MainActor
    func testModalView() throws {
        let surface = SurfaceState(id: "test")
        let props = ModalProperties(
            trigger: "t1",
            content: "c1"
        )
        
        surface.components["t1"] = ComponentInstance(id: "t1", component: .text(.init(text: .init(literal: "Trigger"), variant: nil)))
        surface.components["c1"] = ComponentInstance(id: "c1", component: .text(.init(text: .init(literal: "Inside Modal"), variant: nil)))
        
        let view = A2UIModalView(properties: props)
            .environment(surface)
            
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let vstack = try view.inspect().find(ViewType.VStack.self)
        XCTAssertNotNil(vstack)
        
        // Testing sheets in ViewInspector requires some work, but we can at least find the renderer.
        let renderer = try vstack.find(A2UIComponentRenderer.self).actualView()
        XCTAssertEqual(renderer.componentId, "t1")
    }

    @MainActor
    func testModalWithDirectSurface() throws {
        let surface = SurfaceState(id: "test")
        let props = ModalProperties(trigger: "t1", content: "c1")
        surface.components["t1"] = ComponentInstance(id: "t1", component: .text(.init(text: .init(literal: "T"), variant: nil)))
        surface.components["c1"] = ComponentInstance(id: "c1", component: .text(.init(text: .init(literal: "C"), variant: nil)))
        
        let view = A2UIModalView(properties: props, surface: surface)
            
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        XCTAssertNotNil(try view.inspect().find(A2UIComponentRenderer.self))
    }
}
