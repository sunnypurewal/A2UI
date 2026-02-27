import Testing
import SwiftUI
import ViewInspector
@testable import A2UI

@MainActor
struct A2UIJustifiedContainerTests {
    @Test func justifiedContainerCenter() throws {
        let view = A2UIJustifiedContainer(childIds: ["c1"], justify: .center)
        let inspection = try view.inspect()
        let _ = try inspection.find(ViewType.Spacer.self)
    }

    @Test func justifiedContainerStart() throws {
        let view = A2UIJustifiedContainer(childIds: ["c1"], justify: .start)
        let inspection = try view.inspect()
        let _ = try inspection.find(ViewType.Spacer.self)
    }

    @Test func justifiedContainerEnd() throws {
        let view = A2UIJustifiedContainer(childIds: ["c1"], justify: .end)
        let inspection = try view.inspect()
        let _ = try inspection.find(ViewType.Spacer.self)
    }

    @Test func justifiedContainerSpaceBetween() throws {
        let view = A2UIJustifiedContainer(childIds: ["c1", "c2"], justify: .spaceBetween)
        let inspection = try view.inspect()
        let _ = try inspection.find(ViewType.Spacer.self)
    }
    
    @Test func justifiedContainerStretch() throws {
        let view = A2UIJustifiedContainer(childIds: ["c1"], justify: .stretch)
        let inspection = try view.inspect()
        #expect(throws: (any Error).self) {
            try inspection.find(ViewType.Spacer.self)
        }
    }
}
