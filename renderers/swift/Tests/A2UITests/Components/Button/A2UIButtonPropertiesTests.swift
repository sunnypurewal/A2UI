import Testing
@testable import A2UI

struct A2UIButtonPropertiesTests {
    @Test func buttonVariantId() {
		#expect(ButtonVariant.primary.id == "primary")
        #expect(ButtonVariant.borderless.id == "borderless")
    }

    @Test func buttonPropertiesInit() {
        let action = Action.event(name: "test", context: nil)
        let props = ButtonProperties(child: "testChild", action: action, variant: .primary)
        #expect(props.child == "testChild")
        #expect(props.variant == .primary)
    }
}
