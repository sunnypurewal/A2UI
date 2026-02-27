import XCTest
import SwiftUI
import ViewInspector
@testable import A2UI

final class A2UIListViewTests: XCTestCase {
    @MainActor
    func testVerticalListView() throws {
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
        XCTAssertNotNil(scroll)
        let vstack = try scroll.vStack()
        XCTAssertNotNil(vstack)
    }

    @MainActor
    func testHorizontalListView() throws {
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
        let hstack = try scroll.hStack()
        XCTAssertNotNil(hstack)
    }

    @MainActor
    func testListViewWithTemplate() throws {
        let surface = SurfaceState(id: "test")
        surface.dataModel["items"] = ["a", "b", "c"]
        
        let template = Template(
            componentId: "tmpl",
            path: "items"
        )
        
        let props = ListProperties(
            children: .template(template),
            direction: "vertical",
            align: "start"
        )
        
        let view = A2UIListView(properties: props, surface: surface)
            
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }
        
        let scroll = try view.inspect().find(ViewType.ScrollView.self)
        XCTAssertNotNil(scroll)
        
        let ids = surface.expandTemplate(template: template)
        XCTAssertEqual(ids.count, 3)
    }
    
    @MainActor
    func testListViewWithDirectSurface() throws {
        let surface = SurfaceState(id: "test")
        let props = ListProperties(
            children: .list(["c1"]),
            direction: "vertical",
            align: "start"
        )
        surface.components["c1"] = ComponentInstance(id: "c1", component: .text(.init(text: .init(literal: "Item 1"), variant: nil)))
        
        let view = A2UIListView(properties: props, surface: surface)
        
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let scroll = try view.inspect().find(ViewType.ScrollView.self)
        XCTAssertNotNil(scroll)
    }
}
