import XCTest
import SwiftUI
import ViewInspector
@testable import A2UI

final class A2UIButtonViewTests: XCTestCase {
    @MainActor
    func testPrimaryButton() throws {
        let surface = SurfaceState(id: "test")
        surface.components["t1"] = ComponentInstance(id: "t1", component: .text(.init(text: .init(literal: "Click Me"), variant: nil)))
        
        let props = ButtonProperties(
            child: "t1",
            action: .custom(name: "tap", context: nil),
            variant: .primary
        )
        
        let view = A2UIButtonView(id: "b1", properties: props, surface: surface)
        
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let button = try view.inspect().find(ViewType.Button.self)
        XCTAssertNotNil(button)
        
        // Test action triggering
        var actionTriggered = false
        surface.actionHandler = { action in
            if case .custom(let name, _) = action.action {
                if name == "tap" {
                    actionTriggered = true
                }
            }
        }
        
        try button.tap()
        XCTAssertTrue(actionTriggered)
    }

    @MainActor
    func testBorderlessButton() throws {
        let surface = SurfaceState(id: "test")
        surface.components["t1"] = ComponentInstance(id: "t1", component: .text(.init(text: .init(literal: "Click Me"), variant: nil)))
        
        let props = ButtonProperties(
            child: "t1",
            action: .custom(name: "tap", context: nil),
            variant: .borderless
        )
        
        let view = A2UIButtonView(id: "b1", properties: props, surface: surface)
        
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let button = try view.inspect().find(ViewType.Button.self)
        XCTAssertNotNil(button)
    }

    @MainActor
    func testDisabledButtonWithError() throws {
        let surface = SurfaceState(id: "test")
        surface.components["t1"] = ComponentInstance(id: "t1", component: .text(.init(text: .init(literal: "Click Me"), variant: nil)))
        
        let props = ButtonProperties(
            child: "t1",
            action: .custom(name: "tap", context: nil),
            variant: .primary
        )
        
        // Add a failing check
        let checks = [CheckRule(condition: BoundValue<Bool>(literal: false), message: "Error Message")]
        
        let view = A2UIButtonView(id: "b1", properties: props, checks: checks, surface: surface)
        
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let button = try view.inspect().find(ViewType.Button.self)
        XCTAssertTrue(button.isDisabled())
        
        let errorText = try view.inspect().find(text: "Error Message")
        XCTAssertNotNil(errorText)
    }
    
    @MainActor
    func testButtonWithDirectSurface() throws {
        let surface = SurfaceState(id: "test")
        surface.components["t1"] = ComponentInstance(id: "t1", component: .text(.init(text: .init(literal: "Click Me"), variant: nil)))
        let props = ButtonProperties(child: "t1", action: .custom(name: "tap", context: nil), variant: .primary)
        
        let view = A2UIButtonView(id: "b1", properties: props, surface: surface)
        
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let button = try view.inspect().find(ViewType.Button.self)
        XCTAssertNotNil(button)
    }
}
