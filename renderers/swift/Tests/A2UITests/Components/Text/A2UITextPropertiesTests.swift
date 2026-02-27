import Testing
@testable import A2UI

struct A2UITextPropertiesTests {
    @Test func textVariantId() {
        #expect(A2UITextVariant.h1.id == "h1")
        #expect(A2UITextVariant.body.id == "body")
    }
}
