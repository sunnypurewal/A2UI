import XCTest
import SwiftUI
import ViewInspector
@testable import A2UI

final class A2UIIconViewTests: XCTestCase {
    @MainActor
    func testIconView() throws {
        let props = IconProperties(
            name: BoundValue(literal: "star")
        )
        let surface = SurfaceState(id: "test")
        let view = A2UIIconView(properties: props, surface: surface)
            .environment(surface)
            
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let image = try view.inspect().find(ViewType.Image.self)
        XCTAssertNotNil(image)
    }

    @MainActor
    func testIconViewWithMaterialName() throws {
        let props = IconProperties(
            name: BoundValue(literal: "accountCircle")
        )
        let surface = SurfaceState(id: "test")
        let view = A2UIIconView(properties: props, surface: surface)
            
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let image = try view.inspect().find(ViewType.Image.self)
        XCTAssertNotNil(image)
    }

    @MainActor
    func testIconViewWithInvalidName() throws {
        let props = IconProperties(
            name: BoundValue(literal: "invalid_icon_name")
        )
        let surface = SurfaceState(id: "test")
        let view = A2UIIconView(properties: props, surface: surface)
            
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let image = try view.inspect().find(ViewType.Image.self)
        XCTAssertNotNil(image)
    }
}
