import XCTest
import SwiftUI
import ViewInspector
@testable import A2UI

final class A2UITextFieldViewTests: XCTestCase {
    @MainActor
    func testShortTextField() throws {
        let surface = SurfaceState(id: "test")
        let props = TextFieldProperties(
            label: .init(literal: "Short Text"),
            value: .init(path: "textValue"),
            variant: .shortText
        )
        surface.dataModel["textValue"] = "initial"
        
        let view = A2UITextFieldView(id: "tf1", properties: props, surface: surface)
        
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let textField = try view.inspect().find(ViewType.TextField.self)
        XCTAssertEqual(try textField.labelView().text().string(), "Short Text")
        
        // Test binding get
        XCTAssertEqual(try textField.input(), "initial")
        
        // Test binding set
        try textField.setInput("new text")
    }

    @MainActor
    func testObscuredTextField() throws {
        let surface = SurfaceState(id: "test")
        let props = TextFieldProperties(
            label: .init(literal: "Obscured"),
            value: .init(literal: "secret"),
            variant: .obscured
        )
        
        let view = A2UITextFieldView(id: "tf1", properties: props, surface: surface)
        
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let secureField = try view.inspect().find(ViewType.SecureField.self)
        XCTAssertNotNil(secureField)
    }

    @MainActor
    func testLongTextField() throws {
        let surface = SurfaceState(id: "test")
        let props = TextFieldProperties(
            label: .init(literal: "Long"),
            value: .init(literal: "long content"),
            variant: .longText
        )
        
        let view = A2UITextFieldView(id: "tf1", properties: props, surface: surface)
        
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let textEditor = try view.inspect().find(ViewType.TextEditor.self)
        XCTAssertNotNil(textEditor)
        XCTAssertEqual(try textEditor.input(), "long content")
    }

    @MainActor
    func testNumberTextField() throws {
        let surface = SurfaceState(id: "test")
        let props = TextFieldProperties(
            label: .init(literal: "Number"),
            value: .init(literal: "42"),
            variant: .number
        )
        
        let view = A2UITextFieldView(id: "tf1", properties: props, surface: surface)
        
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let textField = try view.inspect().find(ViewType.TextField.self)
        XCTAssertNotNil(textField)
    }
}
