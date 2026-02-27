import XCTest
import SwiftUI
import ViewInspector
@testable import A2UI

final class A2UICheckBoxViewTests: XCTestCase {
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
}
