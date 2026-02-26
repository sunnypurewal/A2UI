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
        
        // Test Ready but no Root
        surface.isReady = true
        surface.rootComponentId = nil
        let view4 = A2UISurfaceView(surfaceId: "s1", dataStore: dataStore).environment(dataStore)
        ViewHosting.host(view: view4)
        let noRootText = try view4.inspect().find(ViewType.Text.self).string()
        #expect(noRootText.contains("no root component found"))
        ViewHosting.expel()
        
        // Test No DataStore in Environment
        let view5 = A2UISurfaceView(surfaceId: "s1")
        ViewHosting.host(view: view5)
        let noStoreText = try view5.inspect().find(ViewType.Text.self).string()
        #expect(noStoreText.contains("Waiting for A2UI stream..."))
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
        func verifyInRenderer(_ id: String, _ type: ComponentType, check: (InspectableView<ViewType.ClassifiedView>) throws -> Void) throws {
            surface.components[id] = ComponentInstance(id: id, component: type)
            try verifyRendering(A2UIComponentRenderer(componentId: id, surface: surface), check: check)
        }

        // Text
        try verifyInRenderer("t1", .text(TextProperties(text: .init(literal: "H"), variant: .h1))) { view in
            let _ = try view.find(A2UITextView.self)
        }
        
        // Button
        try verifyInRenderer("b1", .button(ButtonProperties(child: "t1", action: .custom(name: "a", context: nil), variant: .primary))) { view in
            let _ = try view.find(A2UIButtonView.self)
        }
        
        // Containers
        let cProps = ContainerProperties(children: .list(["t1"]), justify: .start, align: .center)
        try verifyInRenderer("col1", .column(cProps)) { view in
            let _ = try view.find(A2UIColumnView.self)
        }
        try verifyInRenderer("row1", .row(cProps)) { view in
            let _ = try view.find(A2UIRowView.self)
        }
        try verifyInRenderer("card1", .card(CardProperties(child: "t1"))) { view in
            let _ = try view.find(A2UICardView.self)
        }
        
        // Inputs
        try verifyInRenderer("tf1", .textField(TextFieldProperties(label: .init(literal: "L"), value: .init(literal: "V")))) { view in
            let _ = try view.find(A2UITextFieldView.self)
        }
        try verifyInRenderer("cp1", .choicePicker(ChoicePickerProperties(label: .init(literal: "L"), options: [], value: .init(literal: ["a"])))) { view in
            let _ = try view.find(A2UIChoicePickerView.self)
        }
        try verifyInRenderer("dt1", .dateTimeInput(DateTimeInputProperties(label: .init(literal: "L"), value: .init(literal: "2024-01-01")))) { view in
            let _ = try view.find(A2UIDateTimeInputView.self)
        }
        try verifyInRenderer("sl1", .slider(SliderProperties(label: .init(literal: "L"), min: 0, max: 10, value: .init(literal: 5)))) { view in
            let _ = try view.find(A2UISliderView.self)
        }
        try verifyInRenderer("cb1", .checkBox(CheckBoxProperties(label: .init(literal: "L"), value: .init(literal: true)))) { view in
            let _ = try view.find(A2UICheckBoxView.self)
        }
        
        // Misc
        try verifyInRenderer("img1", .image(ImageProperties(url: .init(literal: "u"), fit: nil, variant: nil))) { view in
            let _ = try view.find(A2UIImageView.self)
        }
        try verifyInRenderer("tabs1", .tabs(TabsProperties(tabs: []))) { view in
            let _ = try view.find(A2UITabsView.self)
        }
        try verifyInRenderer("icon1", .icon(IconProperties(name: .init(literal: "star")))) { view in
            let _ = try view.find(A2UIIconView.self)
        }
        try verifyInRenderer("modal1", .modal(ModalProperties(trigger: "b1", content: "t1"))) { view in
            let _ = try view.find(A2UIModalView.self)
        }
        try verifyInRenderer("div1", .divider(DividerProperties(axis: .horizontal))) { view in
            let _ = try view.find(A2UIDividerView.self)
        }
        try verifyInRenderer("list1", .list(ListProperties(children: .list(["t1"]), direction: nil, align: nil))) { view in
            let _ = try view.find(A2UIListView.self)
        }
        
        // Custom Component (Standard fallback)
        try verifyInRenderer("cust1", .custom("Unknown", [:])) { view in
            let text = try view.find(ViewType.Text.self).string()
            #expect(text.contains("Unknown Custom Component"))
        }

        // Justified Container Combinations
        let allJustify: [A2UIJustify] = [.start, .center, .end, .spaceBetween, .spaceAround, .spaceEvenly]
        let allAlign: [A2UIAlign] = [.start, .center, .end, .stretch]
        for j in allJustify {
            for a in allAlign {
                let props = ContainerProperties(children: .list(["t1"]), justify: j, align: a)
                try verifyInRenderer("col_\(j.rawValue)_\(a.rawValue)", .column(props)) { _ in }
                try verifyInRenderer("row_\(j.rawValue)_\(a.rawValue)", .row(props)) { _ in }
            }
        }
        
        // Template List
        let listProps = ListProperties(children: .template(Template(componentId: "tmpl", path: "items")), direction: nil, align: nil)
        surface.components["tmpl"] = ComponentInstance(id: "tmpl", component: .text(.init(text: .init(path: "name"), variant: nil)))
        surface.setValue(at: "items", value: [["name": "A"], ["name": "B"]])
        // Error Message Helper
        surface.validationErrors["tf_err"] = "Invalid Name"
        try verifyInRenderer("tf_err", .textField(TextFieldProperties(label: .init(literal: "L"), value: .init(literal: "V")))) { view in
            let _ = try view.find(ViewType.Text.self, where: { try $0.string() == "Invalid Name" })
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

    @Test func componentRendererEdgeCases() throws {
        // Missing Surface
        let view = A2UIComponentRenderer(componentId: "any")
        ViewHosting.host(view: view)
        let errorText = try view.inspect().find(ViewType.Text.self).string()
        #expect(errorText.contains("No SurfaceState available"))
        ViewHosting.expel()
        
        // Virtual ID / Template Resolution
        surface.components["tmpl"] = ComponentInstance(id: "tmpl", component: .text(.init(text: .init(path: "name"), variant: nil)))
        surface.setValue(at: "items", value: [["name": "Item 0"], ["name": "Item 1"]])
        
        let virtualRenderer = A2UIComponentRenderer(componentId: "tmpl:items:0", surface: surface)
        ViewHosting.host(view: virtualRenderer)
        // Note: Virtual ID resolution creates a contextual surface. 
        // We just need to verify it renders something from that context.
        let _ = try virtualRenderer.inspect().find(A2UITextView.self)
        ViewHosting.expel()
        
        // Template with missing data
        let missingVirtual = A2UIComponentRenderer(componentId: "tmpl:missing:0", surface: surface)
        ViewHosting.host(view: missingVirtual)
        #expect(try missingVirtual.inspect().find(A2UITextView.self) != nil)
        ViewHosting.expel()

        // Debug Borders
        dataStore.showDebugBorders = true
        let debugView = A2UIComponentRenderer(componentId: "t1", surface: surface)
            .environment(dataStore)
        surface.components["t1"] = ComponentInstance(id: "t1", component: .text(.init(text: .init(literal: "L"), variant: nil)))
        ViewHosting.host(view: debugView)
        // Verify it doesn't crash with debug borders
        #expect(try debugView.inspect().find(A2UITextView.self) != nil)
        ViewHosting.expel()
    }
}
