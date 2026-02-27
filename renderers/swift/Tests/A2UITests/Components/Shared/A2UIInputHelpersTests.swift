import Testing
import SwiftUI
import ViewInspector
@testable import A2UI

@MainActor
struct A2UIInputHelpersTests {
    @Test func resolveValue() {
        let surface = SurfaceState(id: "test")
        let binding = BoundValue<String>(literal: "hello")
        let resolved = A2UI.resolveValue(surface, binding: binding)
        #expect(resolved == "hello")
        
        let nilBinding: BoundValue<String>? = nil
        #expect(A2UI.resolveValue(surface, binding: nilBinding) == nil)
    }

    @Test func updateBinding() {
        let surface = SurfaceState(id: "test")
        var actionTriggered = false
        surface.actionHandler = { action in
            if case .dataUpdate(let update) = action.action {
                #expect(update.path == "testPath")
                #expect(update.contents.value as? String == "newValue")
                actionTriggered = true
            }
        }
        
        let binding = BoundValue<String>(path: "testPath")
        A2UI.updateBinding(surface: surface, binding: binding, newValue: "newValue")
        #expect(actionTriggered)
    }

    @Test func errorMessage() {
        let surface = SurfaceState(id: "test")
        surface.dataModel["val"] = 5
        let check = CheckRule(condition: BoundValue<Bool>(literal: false), message: "Fail")
        
        let message = A2UI.errorMessage(surface: surface, checks: [check])
        #expect(message == "Fail")
        
        let passCheck = CheckRule(condition: BoundValue<Bool>(literal: true), message: "Pass")
        let noMessage = A2UI.errorMessage(surface: surface, checks: [passCheck])
        #expect(noMessage == nil)
    }

    @Test func validationErrorMessageView() throws {
        let surface = SurfaceState(id: "test")
        surface.validationErrors["c1"] = "Error"
        
        let view = ValidationErrorMessageView(id: "c1", surface: surface)
        let text = try view.inspect().find(text: "Error")
        #expect(text != nil)
        
        let noErrorView = ValidationErrorMessageView(id: "c2", surface: surface)
        #expect(throws: (any Error).self) {
             try noErrorView.inspect().find(ViewType.Text.self)
        }
    }
}
