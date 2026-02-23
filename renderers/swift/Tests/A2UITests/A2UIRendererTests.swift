import XCTest
import SwiftUI
@testable import A2UI

@MainActor
final class A2UIRendererTests: XCTestCase {
    var surface: SurfaceState!
    var parser: A2UIParser!
    var dataStore: A2UIDataStore!

    override func setUp() async throws {
        try await super.setUp()
        dataStore = A2UIDataStore()
        surface = SurfaceState(id: "test-surface")
        parser = A2UIParser()
    }

    // MARK: - Component Rendering Tests

    func testComponentRendererDispatch() {
        let textProps = TextProperties(text: .init(literal: "Hello"), usageHint: nil)
        surface.components["t1"] = ComponentInstance(id: "t1", weight: nil, component: .text(textProps))
        
        let renderer = A2UIComponentRenderer(componentId: "t1")
            .environment(surface)
            .environment(dataStore)
        XCTAssertNotNil(renderer)
        
        let missingRenderer = A2UIComponentRenderer(componentId: "missing")
            .environment(surface)
            .environment(dataStore)
        XCTAssertNotNil(missingRenderer)
    }

    func testRendererSwitchExhaustion() {
        let action = Action.createCustom(name: "test")
        let boundStr = BoundValue<String>(literal: "test")
        let boundBool = BoundValue<Bool>(literal: true)
        let boundNum = BoundValue<Double>(literal: 42)
        let children = Children(explicitList: ["c1"])

        let componentTypes: [ComponentType] = [
            .text(TextProperties(text: boundStr)),
            .button(ButtonProperties(label: boundStr, action: action)),
            .row(ContainerProperties(children: children)),
            .column(ContainerProperties(children: children)),
            .card(CardProperties(child: "c1")),
            .image(ImageProperties(url: boundStr)),
            .icon(IconProperties(name: boundStr)),
            // .video(MediaProperties(url: boundStr)),
            // .audioPlayer(MediaProperties(url: boundStr)),
            .divider(DividerProperties()),
            .list(ListProperties(children: children)),
            .tabs(TabsProperties(tabItems: [TabItem(title: boundStr, child: "c1")])),
            .modal(ModalProperties(entryPointChild: "e1", contentChild: "c1")),
            .textField(TextFieldProperties(label: boundStr)),
            .checkBox(CheckBoxProperties(label: boundStr, value: boundBool)),
            .dateTimeInput(DateTimeInputProperties(label: boundStr, value: boundStr)),
            .multipleChoice(MultipleChoiceProperties(label: boundStr, selections: [])),
            .slider(SliderProperties(label: boundStr, value: boundNum)),
            .custom("MyCustom", [:])
        ]

        for (index, type) in componentTypes.enumerated() {
            let id = "comp_\(index)"
            surface.components[id] = ComponentInstance(id: id, weight: nil, component: type)
            render(A2UIComponentRenderer(componentId: id).environment(surface).environment(dataStore))
        }
    }

    func testButtonActionTrigger() {
        let expectation = XCTestExpectation(description: "Button clicked")
        let action = Action.createCustom(name: "test")
        let props = ButtonProperties(label: .init(literal: "Click"), action: action)
        
        surface.actionHandler = { action in
            XCTAssertEqual(action.action.name, "test")
            expectation.fulfill()
        }
        
        let view = A2UIButtonView(properties: props).environment(surface).environment(dataStore)
        render(view)
    }

    func testTextFieldUpdate() {
        let props = TextFieldProperties(label: .init(literal: "L"), value: .init(literal: "initial"))
        let view = A2UITextFieldView(properties: props).environment(surface).environment(dataStore)
        render(view)
    }

    func testSurfaceViewRendering() {
        dataStore.process(chunk: "{\"beginRendering\":{\"surfaceId\":\"s1\",\"root\":\"r1\"}}\n")
        dataStore.process(chunk: "{\"surfaceUpdate\":{\"surfaceId\":\"s1\",\"components\":[{\"id\":\"r1\",\"component\":{\"Text\":{\"text\":\"Root\"}}}]}}\n")
        
        let view = A2UISurfaceView(surfaceId: "s1").environment(dataStore)
        render(view)
        
        XCTAssertNotNil(dataStore.surfaces["s1"])
        XCTAssertTrue(dataStore.surfaces["s1"]?.isReady ?? false)
    }

    // MARK: - View Component Initialization

    /// A helper to force SwiftUI to evaluate the 'body' of a view.
    private func render(_ view: some View) {
        #if os(macOS)
        let hosting = NSHostingController(rootView: view)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 100, height: 100),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.contentView = hosting.view
        window.orderFront(nil) // Force it into the responder chain/render loop
        #else
        let hosting = UIHostingController(rootView: view)
        // For iOS, just setting the frame is usually enough in a unit test, 
        // but adding to a window if available helps.
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.rootViewController = hosting
        window.makeKeyAndVisible()
        #endif
        
        // Spin the run loop to allow SwiftUI to evaluate the body
        let expectation = XCTestExpectation(description: "render")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testNewComponentsInitialization() {
        // Media
        let imageProps = ImageProperties(url: .init(literal: "http://example.com/i.png"), altText: nil, width: nil, height: nil)
        render(A2UIImageView(properties: imageProps).environment(surface).environment(dataStore))
        
        // Inputs
        let tfProps = TextFieldProperties(label: .init(literal: "L"), value: nil, placeholder: nil, type: nil, action: nil)
        render(A2UITextFieldView(properties: tfProps).environment(surface).environment(dataStore))
        
        let cbProps = CheckBoxProperties(label: .init(literal: "L"), value: .init(literal: true), action: nil)
        render(A2UICheckBoxView(properties: cbProps).environment(surface).environment(dataStore))
        
        let sliderProps = SliderProperties(label: nil, value: .init(literal: 50), min: 0, max: 100, step: 1, action: nil)
        render(A2UISliderView(properties: sliderProps).environment(surface).environment(dataStore))
        
        // Layout/Container
        let tabsProps = TabsProperties(tabItems: [TabItem(title: .init(literal: "T1"), child: "c1")])
        render(A2UITabsView(properties: tabsProps).environment(surface).environment(dataStore))
        
        let modalProps = ModalProperties(entryPointChild: "e1", contentChild: "c1", isOpen: nil)
        render(A2UIModalView(properties: modalProps).environment(surface).environment(dataStore))
    }

    func testExhaustiveComponentRendering() {
        // Text components
        render(A2UITextView(properties: TextProperties(text: .init(literal: "Heading"), usageHint: "h1")).environment(surface).environment(dataStore))
        render(A2UITextView(properties: TextProperties(text: .init(literal: "Text"))).environment(surface).environment(dataStore))
        
        // Button
        let buttonProps = ButtonProperties(label: .init(literal: "Click Me"), action: Action.createCustom(name: "test"))
        render(A2UIButtonView(properties: buttonProps).environment(surface).environment(dataStore))
        
        // Containers
        let containerProps = ContainerProperties(children: .init(explicitList: ["c1", "c2"]))
        render(A2UIRowView(properties: containerProps).environment(surface).environment(dataStore))
        render(A2UIColumnView(properties: containerProps).environment(surface).environment(dataStore))
        
        let listProps = ListProperties(children: .init(explicitList: ["c1"]), scrollable: true)
        render(A2UIListView(properties: listProps).environment(surface).environment(dataStore))
        
        // Layout
        render(A2UIDividerView().environment(surface).environment(dataStore))
        render(A2UIIconView(properties: .init(name: .init(literal: "star"))).environment(surface).environment(dataStore))
        
        // More Inputs
        let mcProps = MultipleChoiceProperties(label: .init(literal: "Pick"), selections: [SelectionOption(label: .init(literal: "O1"), value: "v1")], type: "dropdown")
        render(A2UIMultipleChoiceView(properties: mcProps).environment(surface).environment(dataStore))
        
        let radioProps = MultipleChoiceProperties(label: .init(literal: "Pick"), selections: [SelectionOption(label: .init(literal: "O1"), value: "v1")], type: "radio")
        render(A2UIMultipleChoiceView(properties: radioProps).environment(surface).environment(dataStore))
        
        let dtProps = DateTimeInputProperties(label: .init(literal: "Date"), value: .init(literal: "2024-01-01"), type: "date")
        render(A2UIDateTimeInputView(properties: dtProps).environment(surface).environment(dataStore))
        
        let timeProps = DateTimeInputProperties(label: .init(literal: "Time"), value: .init(literal: "12:00"), type: "time")
        render(A2UIDateTimeInputView(properties: timeProps).environment(surface).environment(dataStore))
    }

    // MARK: - Decoding Tests (V0.8 Compliance)

    func testFullV08MessageDecoding() throws {
        // Single-line JSON for decoding test
        let json = #"{"surfaceUpdate":{"surfaceId":"s1","components":[{"id":"t1","component":{"Text":{"text":"Hello"}}},{"id":"i1","component":{"Image":{"url":"http://img"}}},{"id":"v1","component":{"Video":{"url":"http://vid"}}},{"id":"a1","component":{"AudioPlayer":{"url":"http://aud"}}},{"id":"d1","component":{"Divider":{}}},{"id":"tf1","component":{"TextField":{"label":"Name"}}},{"id":"cb1","component":{"CheckBox":{"label":"Agree","value":true}}},{"id":"sl1","component":{"Slider":{"value":50}}},{"id":"mc1","component":{"MultipleChoice":{"selections":[{"label":"O1","value":"v1"}]}}},{"id":"dt1","component":{"DateTimeInput":{"label":"Date","value":"2024"}}}]}}"#
        
        let messages = try parser.parse(line: json)
        
        if case .surfaceUpdate(let update) = messages.first {
            XCTAssertEqual(update.components.count, 10)
        } else {
            XCTFail("Should be surfaceUpdate")
        }
    }
}
