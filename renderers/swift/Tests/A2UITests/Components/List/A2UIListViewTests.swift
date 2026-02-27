import Testing
import SwiftUI
import ViewInspector
@testable import A2UI

@MainActor
struct A2UIListViewTests {
    @Test func verticalListView() throws {
        let surface = SurfaceState(id: "test")
        let props = ListProperties(
            children: .list(["c1", "c2"]),
            direction: "vertical",
            align: "start"
        )
        surface.components["c1"] = ComponentInstance(id: "c1", component: .text(.init(text: .init(literal: "Item 1"), variant: nil)))
        surface.components["c2"] = ComponentInstance(id: "c2", component: .text(.init(text: .init(literal: "Item 2"), variant: nil)))
        
        let view = A2UIListView(properties: props, surface: surface)
        
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let scroll = try view.inspect().find(ViewType.ScrollView.self)
        #expect(scroll != nil)
        #expect(try scroll.vStack() != nil)
    }

    @Test func horizontalListView() throws {
        let surface = SurfaceState(id: "test")
        let props = ListProperties(
            children: .list(["c1"]),
            direction: "horizontal",
            align: "start"
        )
        surface.components["c1"] = ComponentInstance(id: "c1", component: .text(.init(text: .init(literal: "Item 1"), variant: nil)))
        
        let view = A2UIListView(properties: props, surface: surface)
        
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let scroll = try view.inspect().find(ViewType.ScrollView.self)
        #expect(try scroll.hStack() != nil)
    }
}
