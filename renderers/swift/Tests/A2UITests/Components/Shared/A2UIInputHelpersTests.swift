import XCTest
import SwiftUI
import ViewInspector
@testable import A2UI

final class A2UIInputHelpersTests: XCTestCase {
    @MainActor
    func testResolveValue() {
        let surface = SurfaceState(id: "test")
        let binding = BoundValue<String>(literal: "hello")
        let resolved = resolveValue(surface, binding: binding)
        XCTAssertEqual(resolved, "hello")
        
        let nilBinding: BoundValue<String>? = nil
        XCTAssertNil(resolveValue(surface, binding: nilBinding))
    }

    @MainActor
    func testUpdateBinding() {
        let surface = SurfaceState(id: "test")
        var actionTriggered = false
        surface.actionHandler = { action in
            if case .dataUpdate(let update) = action.action {
                XCTAssertEqual(update.path, "testPath")
                XCTAssertEqual(update.contents.value as? String, "newValue")
                actionTriggered = true
            }
        }
        
        let binding = BoundValue<String>(path: "testPath")
        updateBinding(surface: surface, binding: binding, newValue: "newValue")
        XCTAssertTrue(actionTriggered)
    }

    @MainActor
    func testErrorMessage() {
        let surface = SurfaceState(id: "test")
        surface.dataModel["val"] = 5
        let check = CheckRule(condition: BoundValue<Bool>(literal: false), message: "Fail")
        
        let message = errorMessage(surface: surface, checks: [check])
        XCTAssertEqual(message, "Fail")
        
        let passCheck = CheckRule(condition: BoundValue<Bool>(literal: true), message: "Pass")
        let noMessage = errorMessage(surface: surface, checks: [passCheck])
        XCTAssertNil(noMessage)
    }

    @MainActor
    func testValidationErrorMessageView() throws {
        let surface = SurfaceState(id: "test")
        surface.validationErrors["c1"] = "Error"
        
        let view = ValidationErrorMessageView(id: "c1", surface: surface)
        let text = try view.inspect().find(text: "Error")
        XCTAssertNotNil(text)
        
        let noErrorView = ValidationErrorMessageView(id: "c2", surface: surface)
        XCTAssertThrowsError(try noErrorView.inspect().find(ViewType.Text.self))
    }
}
