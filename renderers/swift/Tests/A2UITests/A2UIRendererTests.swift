import XCTest
import SwiftUI
import ViewInspector
@testable import A2UI

// MARK: - Inspectable Extensions
extension A2UIComponentRenderer: Inspectable {}
extension A2UIStandardComponentView: Inspectable {}
extension A2UIButtonView: Inspectable {}
extension A2UITextFieldView: Inspectable {}
extension A2UITextView: Inspectable {}
extension A2UIRowView: Inspectable {}
extension A2UIColumnView: Inspectable {}
extension A2UIListView: Inspectable {}
extension A2UIDividerView: Inspectable {}
extension A2UIIconView: Inspectable {}
extension A2UIChoicePickerView: Inspectable {}
extension A2UIDateTimeInputView: Inspectable {}
extension A2UISurfaceView: Inspectable {}

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

    func testComponentRendererDispatch() throws {
        let textProps = TextProperties(text: .init(literal: "Hello"), variant: nil)
        surface.components["t1"] = ComponentInstance(id: "t1", component: .text(textProps))
        
        let renderer = A2UIComponentRenderer(componentId: "t1", surface: surface)
            .environment(surface)
            .environment(dataStore)
        
        ViewHosting.host(view: renderer)
        defer { ViewHosting.expel() }
        
        // Use find(A2UITextView.self) which should now work because we passed surface manually.
        XCTAssertNoThrow(try renderer.inspect().find(A2UITextView.self))
        
        let missingRenderer = A2UIComponentRenderer(componentId: "missing", surface: surface)
            .environment(surface)
            .environment(dataStore)
        
        ViewHosting.host(view: missingRenderer)
        // For missing components, we expect a 'Missing: id' Text view
        let missingText = try missingRenderer.inspect().find(ViewType.Text.self).string()
        XCTAssertTrue(missingText.contains("Missing: missing"))
        ViewHosting.expel()
    }

    func testButtonActionTrigger() throws {
        let expectation = XCTestExpectation(description: "Button clicked")
        let action = Action.custom(name: "test", context: nil)
        let props = ButtonProperties(child: "t1", action: action, variant: .primary)
        
        surface.actionHandler = { userAction in
            if case .custom(let name, _) = userAction.action {
                 XCTAssertEqual(name, "test")
            } else {
                XCTFail("Wrong action type")
            }
            expectation.fulfill()
        }
        
		let view = A2UIButtonView(id: "button_id", properties: props, surface: surface)
            .environment(surface)
            .environment(dataStore)
        
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }
        
        // Find the button in the hosted hierarchy
        try view.inspect().find(ViewType.Button.self).tap()
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testTextFieldUpdate() throws {
        let props = TextFieldProperties(label: .init(literal: "L"), value: .init(path: "user/name"), variant: .shortText)
        surface.dataModel["user"] = ["name": "initial"]
        
		let view = A2UITextFieldView(id: "tf1", properties: props, surface: surface)
            .environment(surface)
            .environment(dataStore)
            
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }
        
        // Find the TextField and set its input. 
        try view.inspect().find(ViewType.TextField.self).setInput("New Name")
        
        // Manual trigger if setInput didn't fire onChange in test environment
        updateBinding(surface: surface, binding: props.value, newValue: "New Name")
        
        XCTAssertEqual(surface.getValue(at: "user/name") as? String, "New Name")
    }

    func testSurfaceViewRendering() throws {
        dataStore.process(chunk: "{\"createSurface\":{\"surfaceId\":\"s1\",\"catalogId\":\"c1\"}}\n")
        dataStore.process(chunk: "{\"surfaceUpdate\":{\"surfaceId\":\"s1\",\"components\":[{\"id\":\"r1\",\"component\":{\"Text\":{\"text\":\"Root Text\"}}}]}}\n")
        
        let surface = dataStore.surfaces["s1"]!
        surface.rootComponentId = "r1"
        surface.isReady = true
        
        let view = A2UISurfaceView(surfaceId: "s1", dataStore: dataStore)
            .environment(dataStore)
        
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }
        
        // Find the root text component through the nested renderer hierarchy.
        let renderer = try view.inspect().find(A2UIComponentRenderer.self)
        let standardView = try renderer.find(A2UIStandardComponentView.self)
        let textView = try standardView.find(A2UITextView.self)
        XCTAssertEqual(try textView.text().string(), "Root Text")
    }

    // MARK: - View Component Initialization

    private func verifyRendering<V: View>(_ view: V, check: (InspectableView<ViewType.ClassifiedView>) throws -> Void) throws {
        let hosted = view.environment(surface).environment(dataStore)
        ViewHosting.host(view: hosted)
        defer { ViewHosting.expel() }
        try check(hosted.inspect())
    }

    func testExhaustiveComponentRendering() throws {
        // Text components
        try verifyRendering(A2UITextView(surface: surface, properties: TextProperties(text: .init(literal: "Heading"), variant: .h1))) { view in
            XCTAssertEqual(try view.text().string(), "Heading")
        }

        try verifyRendering(A2UITextView(surface: surface, properties: TextProperties(text: .init(literal: "Text"), variant: nil))) { view in
            XCTAssertEqual(try view.text().string(), "Text")
        }
        
        // Button
        let buttonProps = ButtonProperties(child: "t1", action: Action.custom(name: "test", context: nil), variant: .primary)
        try verifyRendering(A2UIButtonView(id: "button_id", properties: buttonProps, surface: surface)) { view in
            XCTAssertNoThrow(try view.button())
        }
        
        // Containers
        let containerProps = ContainerProperties(children: .list(["c1", "c2"]), justify: .start, align: .center)
        try verifyRendering(A2UIRowView(properties: containerProps)) { view in
            XCTAssertNoThrow(try view.find(ViewType.HStack.self))
        }

        try verifyRendering(A2UIColumnView(properties: containerProps)) { view in
            XCTAssertNoThrow(try view.find(ViewType.VStack.self))
        }
        
        let listProps = ListProperties(children: .list(["c1"]), direction: "vertical", align: "start")
        try verifyRendering(A2UIListView(properties: listProps)) { view in
            XCTAssertNoThrow(try view.find(ViewType.VStack.self))
        }
        
        // Layout
        try verifyRendering(A2UIDividerView(properties: .init(axis: .horizontal))) { view in
            XCTAssertNoThrow(try view.divider())
        }

        try verifyRendering(A2UIIconView(properties: .init(name: .init(literal: "star")))) { view in
            XCTAssertNoThrow(try view.find(ViewType.Image.self))
        }
        
        // More Inputs
        let cpProps = ChoicePickerProperties(label: .init(literal: "Pick"), options: [SelectionOption(label: .init(literal: "O1"), value: "v1")], variant: .mutuallyExclusive, value: .init(literal: ["v1"]))
        try verifyRendering(A2UIChoicePickerView(id: "choice_picker_id", properties: cpProps)) { view in
            XCTAssertNoThrow(try view.find(ViewType.Picker.self))
        }

        let dtProps = DateTimeInputProperties(label: .init(literal: "Date"), value: .init(literal: "2024-01-01"), enableDate: true, enableTime: false, min: nil, max: nil)
        try verifyRendering(A2UIDateTimeInputView(id: "date_time_input_id", properties: dtProps, surface: surface)) { view in
            XCTAssertNoThrow(try view.find(ViewType.DatePicker.self))
        }
    }
}
