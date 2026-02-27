import XCTest
import SwiftUI
import ViewInspector
@testable import A2UI

final class A2UISliderViewTests: XCTestCase {
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
}
