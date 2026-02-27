import XCTest
@testable import A2UI

final class ContainerPropertiesTests: XCTestCase {
    func testResolvedJustify() {
        let props = ContainerProperties(children: .list([]), justify: nil, align: nil)
        XCTAssertEqual(props.resolvedJustify, .spaceBetween)
        
        let props2 = ContainerProperties(children: .list([]), justify: .center, align: nil)
        XCTAssertEqual(props2.resolvedJustify, .center)
    }

    func testResolvedAlign() {
        let props = ContainerProperties(children: .list([]), justify: nil, align: nil)
        XCTAssertEqual(props.resolvedAlign, .center)
        
        let props2 = ContainerProperties(children: .list([]), justify: nil, align: .start)
        XCTAssertEqual(props2.resolvedAlign, .start)
    }
    
    func testJustifyEnum() {
        XCTAssertEqual(A2UIJustify.center.rawValue, "center")
        XCTAssertEqual(A2UIJustify.center.id, "center")
    }

    func testAlignEnum() {
        XCTAssertEqual(A2UIAlign.start.rawValue, "start")
        XCTAssertEqual(A2UIAlign.start.id, "start")
    }
}
