import XCTest
import SwiftUI
import ViewInspector
@testable import A2UI

final class A2UIListViewTests: XCTestCase {
    @MainActor
    func testListView() throws {
        let surface = SurfaceState(id: "test")
        let props = ListProperties(
            children: .list(["c1", "c2"]),
            direction: "vertical",
            align: "start"
        )
        surface.components["c1"] = ComponentInstance(id: "c1", component: .text(.init(text: .init(literal: "Item 1"), variant: nil)))
        surface.components["c2"] = ComponentInstance(id: "c2", component: .text(.init(text: .init(literal: "Item 2"), variant: nil)))
        
        let view = A2UIListView(properties: props)
            .environment(surface)
        
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let list = try view.inspect().find(ViewType.ScrollView.self)
        XCTAssertNotNil(list)
    }
}
