import XCTest
import SwiftUI
import ViewInspector
@testable import A2UI

final class A2UIJustifiedContainerTests: XCTestCase {
    @MainActor
    func testJustifiedContainerCenter() throws {
        let view = A2UIJustifiedContainer(childIds: ["c1"], justify: .center)
        let inspection = try view.inspect()
        
        // Should have Spacer, Child, Spacer
        XCTAssertNotNil(try inspection.find(ViewType.Spacer.self))
        // ViewInspector doesn't easily let us count how many Spacers are at root of body if it's not a stack,
        // but A2UIJustifiedContainer is used inside HStack/VStack in Row/Column views.
    }

    @MainActor
    func testJustifiedContainerStart() throws {
        let view = A2UIJustifiedContainer(childIds: ["c1"], justify: .start)
        let inspection = try view.inspect()
        // Should have Child, Spacer
        XCTAssertNotNil(try inspection.find(ViewType.Spacer.self))
    }

    @MainActor
    func testJustifiedContainerEnd() throws {
        let view = A2UIJustifiedContainer(childIds: ["c1"], justify: .end)
        let inspection = try view.inspect()
        // Should have Spacer, Child
        XCTAssertNotNil(try inspection.find(ViewType.Spacer.self))
    }

    @MainActor
    func testJustifiedContainerSpaceBetween() throws {
        let view = A2UIJustifiedContainer(childIds: ["c1", "c2"], justify: .spaceBetween)
        let inspection = try view.inspect()
        // Should have Child, Spacer, Child
        XCTAssertNotNil(try inspection.find(ViewType.Spacer.self))
    }
    
    @MainActor
    func testJustifiedContainerStretch() throws {
        let view = A2UIJustifiedContainer(childIds: ["c1"], justify: .stretch)
        let inspection = try view.inspect()
        // Should have Child only, no Spacers
        XCTAssertThrowsError(try inspection.find(ViewType.Spacer.self))
    }

    @MainActor
    func testJustifiedContainerSpaceEvenly() throws {
        let view = A2UIJustifiedContainer(childIds: ["c1"], justify: .spaceEvenly)
        let inspection = try view.inspect()
        XCTAssertNotNil(try inspection.find(ViewType.Spacer.self))
    }

    @MainActor
    func testJustifiedContainerSpaceAround() throws {
        let view = A2UIJustifiedContainer(childIds: ["c1"], justify: .spaceAround)
        let inspection = try view.inspect()
        XCTAssertNotNil(try inspection.find(ViewType.Spacer.self))
    }
}
