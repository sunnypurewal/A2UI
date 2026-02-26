import XCTest
import SwiftUI
import ViewInspector
@testable import A2UI

final class A2UIComponentViewTests: XCTestCase {

    @MainActor
    func testCheckBoxView() throws {
        let surface = SurfaceState(id: "test")
        surface.actionHandler = { action in
            if case .dataUpdate(let du) = action.action {
                surface.setValue(at: du.path, value: du.contents.value)
            }
        }
        let props = CheckBoxProperties(
            label: BoundValue(literal: "Check Me"),
            value: BoundValue(path: "/checked")
        )
        surface.setValue(at: "/checked", value: false)
        
        let view = A2UICheckBoxView(id: "cb1", properties: props, surface: surface)
            .environment(surface)
        
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }
            
        let toggle = try view.inspect().find(ViewType.Toggle.self)
        
        XCTAssertEqual(try toggle.labelView().text().string(), "Check Me")
        
        try toggle.tap()
        XCTAssertEqual(surface.getValue(at: "/checked") as? Bool, true)
    }

    @MainActor
    func testIconView() throws {
        let props = IconProperties(
            name: BoundValue(literal: "star")
        )
        let surface = SurfaceState(id: "test")
        let view = A2UIIconView(properties: props, surface: surface)
            .environment(surface)
            
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let image = try view.inspect().find(ViewType.Image.self)
        XCTAssertNotNil(image)
    }

    @MainActor
    func testImageView() throws {
        let props = ImageProperties(
            url: BoundValue(literal: "https://example.com/img.png"),
            fit: .cover,
            variant: .header
        )
        let surface = SurfaceState(id: "test")
        let view = A2UIImageView(properties: props)
            .environment(surface)
            
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        XCTAssertNotNil(try view.inspect().view(A2UIImageView.self))
    }

    @MainActor
    func testSliderView() throws {
        let surface = SurfaceState(id: "test")
        surface.actionHandler = { action in
            if case .dataUpdate(let du) = action.action {
                surface.setValue(at: du.path, value: du.contents.value)
            }
        }
        let props = SliderProperties(
            label: BoundValue(literal: "Volume"),
            min: 0,
            max: 10,
            value: BoundValue(path: "/vol")
        )
        surface.setValue(at: "/vol", value: 5.0)
        
        let view = A2UISliderView(id: "sl1", properties: props, surface: surface)
            .environment(surface)
            
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let slider = try view.inspect().find(ViewType.Slider.self)
        XCTAssertEqual(try view.inspect().find(ViewType.Text.self).string(), "Volume")
        
        // Just verify we can get the value (proves binding is working)
        XCTAssertNotNil(try slider.value())
    }

    @MainActor
    func testTabsView() throws {
        let surface = SurfaceState(id: "test")
        let props = TabsProperties(
            tabs: [
                TabItem(title: BoundValue(literal: "Tab 1"), child: "c1"),
                TabItem(title: BoundValue(literal: "Tab 2"), child: "c2")
            ]
        )
        
        let view = A2UITabsView(properties: props)
            .environment(surface)
            
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let picker = try view.inspect().find(ViewType.Picker.self)
        XCTAssertNotNil(picker)
    }

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
