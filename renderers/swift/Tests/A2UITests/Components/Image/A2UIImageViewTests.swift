import XCTest
import SwiftUI
import ViewInspector
@testable import A2UI

final class A2UIImageViewTests: XCTestCase {
    @MainActor
    func testImageView() throws {
        let props = ImageProperties(
            url: BoundValue(literal: "https://example.com/img.png"),
            fit: .cover,
            variant: .header
        )
        let surface = SurfaceState(id: "test")
        let view = A2UIImageView(properties: props, surface: surface)
            
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let asyncImage = try view.inspect().find(ViewType.AsyncImage.self)
        XCTAssertNotNil(asyncImage)
    }

    @MainActor
    func testImageViewAvatar() throws {
        let props = ImageProperties(
            url: BoundValue(literal: "https://example.com/avatar.png"),
            fit: .cover,
            variant: .avatar
        )
        let surface = SurfaceState(id: "test")
        let view = A2UIImageView(properties: props, surface: surface)
            
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let asyncImage = try view.inspect().find(ViewType.AsyncImage.self)
        XCTAssertNotNil(asyncImage)
    }

    @MainActor
    func testImageViewWithDirectSurface() throws {
        let surface = SurfaceState(id: "test")
        let props = ImageProperties(
            url: BoundValue(literal: "https://example.com/img.png"),
            fit: .contain,
            variant: .header
        )
        let view = A2UIImageView(properties: props, surface: surface)
            
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let asyncImage = try view.inspect().find(ViewType.AsyncImage.self)
        XCTAssertNotNil(asyncImage)
    }
}
