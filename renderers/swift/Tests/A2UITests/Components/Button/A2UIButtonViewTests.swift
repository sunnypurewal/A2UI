import Testing
import SwiftUI
import ViewInspector
@testable import A2UI

@MainActor
struct A2UIButtonViewTests {
    @Test func primaryButton() throws {
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
        // #expect no longer needs nil check for non-optional result from find()
        
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
        #expect(actionTriggered)
    }

    @Test func borderlessButton() throws {
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

        let _ = try view.inspect().find(ViewType.Button.self)
    }

    @Test func disabledButtonWithError() throws {
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
        #expect(button.isDisabled())
        
        let _ = try view.inspect().find(text: "Error Message")
    }
}
