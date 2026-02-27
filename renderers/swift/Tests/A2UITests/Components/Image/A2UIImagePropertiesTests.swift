import XCTest
@testable import A2UI

final class A2UIImagePropertiesTests: XCTestCase {
    func testImageVariantId() {
        XCTAssertEqual(A2UIImageVariant.icon.id, "icon")
        XCTAssertEqual(A2UIImageVariant.avatar.id, "avatar")
    }
    
    func testImageFitId() {
        XCTAssertEqual(A2UIImageFit.contain.id, "contain")
        XCTAssertEqual(A2UIImageFit.cover.id, "cover")
    }
}
