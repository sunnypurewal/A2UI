import XCTest
@testable import A2UI

final class A2UIButtonPropertiesTests: XCTestCase {
    func testButtonVariantId() {
        XCTAssertEqual(ButtonVariant.primary.id, "primary")
        XCTAssertEqual(ButtonVariant.borderless.id, "borderless")
    }

    func testButtonPropertiesInit() {
        let action = Action.custom(name: "test", context: nil)
        let props = ButtonProperties(child: "testChild", action: action, variant: .primary)
        XCTAssertEqual(props.child, "testChild")
        XCTAssertEqual(props.variant, .primary)
    }
}
