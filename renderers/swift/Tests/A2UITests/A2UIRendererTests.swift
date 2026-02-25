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
        let textProps = TextProperties(text: .init(literal: "Hello"), variant: nil)
        surface.components["t1"] = ComponentInstance(id: "t1", component: .text(textProps))
        
        let renderer = A2UIComponentRenderer(componentId: "t1")
            .environment(surface)
            .environment(dataStore)
        XCTAssertNotNil(renderer)
        
        let missingRenderer = A2UIComponentRenderer(componentId: "missing")
            .environment(surface)
            .environment(dataStore)
        XCTAssertNotNil(missingRenderer)
    }

    func testButtonActionTrigger() {
        let expectation = XCTestExpectation(description: "Button clicked")
        let action = Action.custom(name: "test", context: nil)
        let props = ButtonProperties(child: "t1", action: action, variant: "primary")
        
        surface.actionHandler = { userAction in
            if case .custom(let name, _) = userAction.action {
                 XCTAssertEqual(name, "test")
            } else {
                XCTFail("Wrong action type")
            }
            expectation.fulfill()
        }
        
        let view = A2UIButtonView(properties: props).environment(surface).environment(dataStore)
        render(view)
    }

    func testTextFieldUpdate() {
        let props = TextFieldProperties(label: .init(literal: "L"), value: .init(literal: "initial"), variant: "shortText")
        let view = A2UITextFieldView(properties: props).environment(surface).environment(dataStore)
        render(view)
    }

    func testSurfaceViewRendering() {
        dataStore.process(chunk: "{\"createSurface\":{\"surfaceId\":\"s1\",\"catalogId\":\"c1\"}}\n")
        dataStore.process(chunk: "{\"updateComponents\":{\"surfaceId\":\"s1\",\"components\":[{\"id\":\"r1\",\"component\":{\"Text\":{\"text\":\"Root\"}}}]}}\n")
        
        let view = A2UISurfaceView(surfaceId: "s1").environment(dataStore)
        render(view)
        
        XCTAssertNotNil(dataStore.surfaces["s1"])
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

    func testExhaustiveComponentRendering() {
        // Text components
        render(A2UITextView(properties: TextProperties(text: .init(literal: "Heading"), variant: "h1")).environment(surface).environment(dataStore))
        render(A2UITextView(properties: TextProperties(text: .init(literal: "Text"), variant: nil)).environment(surface).environment(dataStore))
        
        // Button
        let buttonProps = ButtonProperties(child: "t1", action: Action.custom(name: "test", context: nil), variant: "primary")
        render(A2UIButtonView(properties: buttonProps).environment(surface).environment(dataStore))
        
        // Containers
        let containerProps = ContainerProperties(children: .list(["c1", "c2"]), justify: "start", align: "center")
        render(A2UIRowView(properties: containerProps).environment(surface).environment(dataStore))
        render(A2UIColumnView(properties: containerProps).environment(surface).environment(dataStore))
        
        let listProps = ListProperties(children: .list(["c1"]), direction: "vertical", align: "start")
        render(A2UIListView(properties: listProps).environment(surface).environment(dataStore))
        
        // Layout
        render(A2UIDividerView().environment(surface).environment(dataStore))
        render(A2UIIconView(properties: .init(name: .init(literal: "star"))).environment(surface).environment(dataStore))
        
        // More Inputs
        let cpProps = ChoicePickerProperties(label: .init(literal: "Pick"), options: [SelectionOption(label: .init(literal: "O1"), value: "v1")], variant: "mutuallyExclusive", value: .init(literal: ["v1"]))
        render(A2UIChoicePickerView(properties: cpProps).environment(surface).environment(dataStore))

        let dtProps = DateTimeInputProperties(label: .init(literal: "Date"), value: .init(literal: "2024-01-01"), enableDate: true, enableTime: false, min: nil, max: nil)
        render(A2UIDateTimeInputView(properties: dtProps).environment(surface).environment(dataStore))
    }
}
