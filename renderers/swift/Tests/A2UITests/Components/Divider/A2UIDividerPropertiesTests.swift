import Testing
@testable import A2UI

struct A2UIDividerPropertiesTests {
    @Test func dividerAxisId() {
        #expect(DividerAxis.horizontal.id == "horizontal")
        #expect(DividerAxis.vertical.id == "vertical")
    }
}
