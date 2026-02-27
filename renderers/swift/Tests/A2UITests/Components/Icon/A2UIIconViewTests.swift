import Testing
import SwiftUI
import ViewInspector
@testable import A2UI

@MainActor
struct A2UIIconViewTests {
    @Test func iconView() throws {
        let props = IconProperties(
            name: BoundValue(literal: "star")
        )
        let surface = SurfaceState(id: "test")
        let view = A2UIIconView(properties: props, surface: surface)
            
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        #expect(try view.inspect().find(ViewType.Image.self) != nil)
    }
}
