import XCTest
@testable import A2UI

final class ComponentInstanceTests: XCTestCase {
    func testComponentInstanceFullInit() throws {
        let textType = ComponentType.text(TextProperties(text: BoundValue(literal: "Test"), variant: nil))
        let check = CheckRule(condition: BoundValue<Bool>(literal: true), message: "msg")
        let comp = ComponentInstance(id: "1", weight: 2.5, checks: [check], component: textType)
        
        XCTAssertEqual(comp.id, "1")
        XCTAssertEqual(comp.weight, 2.5)
        XCTAssertEqual(comp.checks?.count, 1)
        XCTAssertEqual(comp.componentTypeName, "Text")
        
        let encoded = try JSONEncoder().encode(comp)
        let decoded = try JSONDecoder().decode(ComponentInstance.self, from: encoded)
        XCTAssertEqual(decoded.id, "1")
        XCTAssertEqual(decoded.weight, 2.5)
    }
}
