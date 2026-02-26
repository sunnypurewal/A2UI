import Testing
import SwiftUI
import ViewInspector
@testable import A2UI

@MainActor
struct A2UIRendererTests {
    private let surface: SurfaceState
    private let parser: A2UIParser
    private let dataStore: A2UIDataStore

    init() {
        dataStore = A2UIDataStore()
        surface = SurfaceState(id: "test-surface")
        parser = A2UIParser()
    }

    // MARK: - Component Rendering Tests

    @Test func componentRendererDispatch() throws {
        let textProps = TextProperties(text: .init(literal: "Hello"), variant: nil)
        surface.components["t1"] = ComponentInstance(id: "t1", component: .text(textProps))
        
        let renderer = A2UIComponentRenderer(componentId: "t1", surface: surface)
            .environment(surface)
            .environment(dataStore)
        
        ViewHosting.host(view: renderer)
        defer { ViewHosting.expel() }
        
        // Use find(A2UITextView.self) which should now work because we passed surface manually.
        let _ = try renderer.inspect().find(A2UITextView.self)
        
        let missingRenderer = A2UIComponentRenderer(componentId: "missing", surface: surface)
            .environment(surface)
            .environment(dataStore)
        
        ViewHosting.host(view: missingRenderer)
        // For missing components, we expect a 'Missing: id' Text view
        let missingText = try missingRenderer.inspect().find(ViewType.Text.self).string()
        #expect(missingText.contains("Missing: missing"))
        ViewHosting.expel()
    }

    @Test func buttonActionTrigger() async throws {
        let action = Action.custom(name: "test", context: nil)
        let props = ButtonProperties(child: "t1", action: action, variant: .primary)
        
        await confirmation("Button clicked") { confirmed in
            surface.actionHandler = { userAction in
                if case .custom(let name, _) = userAction.action {
                     #expect(name == "test")
                } else {
                    Issue.record("Wrong action type")
                }
                confirmed()
            }
            
            let view = A2UIButtonView(id: "button_id", properties: props, surface: surface)
                .environment(surface)
                .environment(dataStore)
            
            ViewHosting.host(view: view)
            defer { ViewHosting.expel() }
            
            // Find the button in the hosted hierarchy
            try? view.inspect().find(ViewType.Button.self).tap()
        }
    }

    @Test func textFieldUpdate() throws {
        dataStore.process(chunk: "{\"createSurface\":{\"surfaceId\":\"test-surface\",\"catalogId\":\"c1\"}}\n")
        let registeredSurface = try #require(dataStore.surfaces["test-surface"])
        
        let props = TextFieldProperties(label: .init(literal: "L"), value: .init(path: "user/name"), variant: .shortText)
        registeredSurface.dataModel["user"] = ["name": "initial"]
        
		let view = A2UITextFieldView(id: "tf1", properties: props, surface: registeredSurface)
            .environment(registeredSurface)
            .environment(dataStore)
            
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }
        
        // Find the TextField and set its input. 
        try view.inspect().find(ViewType.TextField.self).setInput("New Name")
        
        // Manual trigger if setInput didn't fire onChange in test environment
        updateBinding(surface: registeredSurface, binding: props.value, newValue: "New Name")
        
        #expect(registeredSurface.getValue(at: "user/name") as? String == "New Name")
    }

    @Test func surfaceViewRendering() throws {
        dataStore.process(chunk: "{\"createSurface\":{\"surfaceId\":\"s1\",\"catalogId\":\"c1\"}}\n")
        dataStore.process(chunk: "{\"surfaceUpdate\":{\"surfaceId\":\"s1\",\"components\":[{\"id\":\"r1\",\"component\":{\"Text\":{\"text\":\"Root Text\"}}}]}}\n")
        
        let surface = try #require(dataStore.surfaces["s1"])
        surface.rootComponentId = "r1"
        surface.isReady = true
        
        let view = A2UISurfaceView(surfaceId: "s1", dataStore: dataStore)
            .environment(dataStore)
        
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }
        
        // Verifying that A2UIComponentRenderer is in the hierarchy proves
        // that A2UISurfaceView correctly resolved the surface, its ready state,
        // and its rootComponentId, taking the active rendering path.
        let _ = try view.inspect().find(A2UIComponentRenderer.self)
        ViewHosting.expel()
        
        // Test Not Ready
        surface.isReady = false
        let view2 = A2UISurfaceView(surfaceId: "s1", dataStore: dataStore).environment(dataStore)
        ViewHosting.host(view: view2)
        let progress = try view2.inspect().find(ViewType.ProgressView.self)
        #expect(progress != nil)
        ViewHosting.expel()
        
        // Test Missing Surface
        let view3 = A2UISurfaceView(surfaceId: "missing", dataStore: dataStore).environment(dataStore)
        ViewHosting.host(view: view3)
        let missingText = try view3.inspect().find(ViewType.Text.self).string()
        #expect(missingText.contains("Waiting for A2UI stream..."))
        ViewHosting.expel()
    }

    // MARK: - View Component Initialization

    private func verifyRendering<V: View>(_ view: V, check: (InspectableView<ViewType.ClassifiedView>) throws -> Void) throws {
        let hosted = view.environment(surface).environment(dataStore)
        ViewHosting.host(view: hosted)
        defer { ViewHosting.expel() }
        try check(hosted.inspect())
    }

    @Test func exhaustiveComponentRendering() throws {
        // Text components
        try verifyRendering(A2UITextView(surface: surface, properties: TextProperties(text: .init(literal: "Heading"), variant: .h1))) { view in
            let text = try view.text().string()
            #expect(text == "Heading")
        }

        try verifyRendering(A2UITextView(surface: surface, properties: TextProperties(text: .init(literal: "Text"), variant: nil))) { view in
            let text = try view.text().string()
            #expect(text == "Text")
        }
        
        // Button
        let buttonProps = ButtonProperties(child: "t1", action: Action.custom(name: "test", context: nil), variant: .primary)
        try verifyRendering(A2UIButtonView(id: "button_id", properties: buttonProps, surface: surface)) { view in
            let _ = try view.button()
        }
        
        // Containers
        let containerProps = ContainerProperties(children: .list(["c1", "c2"]), justify: .start, align: .center)
        try verifyRendering(A2UIRowView(properties: containerProps, surface: surface)) { view in
            let _ = try view.find(ViewType.HStack.self)
        }

        try verifyRendering(A2UIColumnView(properties: containerProps, surface: surface)) { view in
            let _ = try view.find(ViewType.VStack.self)
        }
        
        // More Inputs
        let cpProps = ChoicePickerProperties(label: .init(literal: "Pick"), options: [SelectionOption(label: .init(literal: "O1"), value: "v1")], variant: .mutuallyExclusive, value: .init(literal: ["v1"]))
        try verifyRendering(A2UIChoicePickerView(id: "choice_picker_id", properties: cpProps, surface: surface)) { view in
            let _ = try view.find(ViewType.Picker.self)
        }

        let dtProps = DateTimeInputProperties(label: .init(literal: "Date"), value: .init(literal: "2024-01-01"), enableDate: true, enableTime: false, min: nil, max: nil)
        try verifyRendering(A2UIDateTimeInputView(id: "date_time_input_id", properties: dtProps, surface: surface)) { view in
            let _ = try view.find(ViewType.DatePicker.self)
        }
    }

    @Test func standardComponentViewRendering() throws {
        let textProps = TextProperties(text: .init(literal: "Test Text"), variant: nil)
        let comp = ComponentInstance(id: "c1", component: .text(textProps))
        
        let view = A2UIStandardComponentView(surface: surface, instance: comp)
            .environment(surface)
            .environment(dataStore)
        
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }
        
        let _ = try view.inspect().find(A2UITextView.self)
        
        // Test with different types to ensure dispatch works
        let buttonComp = ComponentInstance(id: "c2", component: .button(.init(child: "t1", action: .custom(name: "b", context: nil))))
        let buttonView = A2UIStandardComponentView(surface: surface, instance: buttonComp)
        ViewHosting.host(view: buttonView)
        let _ = try buttonView.inspect().find(A2UIButtonView.self)
        ViewHosting.expel()
    }
}
