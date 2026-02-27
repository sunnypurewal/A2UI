import XCTest
import SwiftUI
import ViewInspector
@testable import A2UI

final class A2UITabsViewTests: XCTestCase {
    @MainActor
    func testTabsView() throws {
        let surface = SurfaceState(id: "test")
        let props = TabsProperties(
            tabs: [
                TabItem(title: BoundValue(literal: "Tab 1"), child: "c1"),
                TabItem(title: BoundValue(literal: "Tab 2"), child: "c2")
            ]
        )
        
        let view = A2UITabsView(properties: props)
            .environment(surface)
            
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let picker = try view.inspect().find(ViewType.Picker.self)
        XCTAssertNotNil(picker)
    }
}
