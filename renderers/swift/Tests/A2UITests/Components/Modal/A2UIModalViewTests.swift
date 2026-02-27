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

        XCTAssertNotNil(try view.inspect().view(A2UIModalView.self))
    }
}
