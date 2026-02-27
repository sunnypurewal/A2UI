import Testing
@testable import A2UI

struct A2UIImagePropertiesTests {
    @Test func imageVariantId() {
        #expect(A2UIImageVariant.icon.id == "icon")
        #expect(A2UIImageVariant.avatar.id == "avatar")
    }
    
    @Test func imageFitId() {
        #expect(A2UIImageFit.contain.id == "contain")
        #expect(A2UIImageFit.cover.id == "cover")
    }
}
