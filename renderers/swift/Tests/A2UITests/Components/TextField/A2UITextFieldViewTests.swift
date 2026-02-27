import Testing
import SwiftUI
import ViewInspector
@testable import A2UI

@MainActor
struct A2UITextFieldViewTests {
    @Test func shortTextField() throws {
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
        #expect(try textField.labelView().text().string() == "Short Text")
        #expect(try textField.input() == "initial")
        
        try textField.setInput("new text")
    }

    @Test func obscuredTextField() throws {
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
        #expect(secureField != nil)
    }

    @Test func longTextField() throws {
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
        #expect(textEditor != nil)
        #expect(try textEditor.input() == "long content")
    }
}
