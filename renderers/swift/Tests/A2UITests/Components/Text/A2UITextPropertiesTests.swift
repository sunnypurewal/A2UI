import XCTest
@testable import A2UI

final class A2UITextPropertiesTests: XCTestCase {
    func testTextVariantId() {
        XCTAssertEqual(A2UITextVariant.h1.id, "h1")
        XCTAssertEqual(A2UITextVariant.body.id, "body")
    }
}
