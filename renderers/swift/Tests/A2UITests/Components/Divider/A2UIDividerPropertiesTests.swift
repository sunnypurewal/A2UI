import XCTest
@testable import A2UI

final class A2UIDividerPropertiesTests: XCTestCase {
    func testDividerAxisId() {
        XCTAssertEqual(DividerAxis.horizontal.id, "horizontal")
        XCTAssertEqual(DividerAxis.vertical.id, "vertical")
    }
}
