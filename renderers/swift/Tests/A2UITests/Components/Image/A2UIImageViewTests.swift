import Testing
import SwiftUI
import ViewInspector
@testable import A2UI

@MainActor
struct A2UIImageViewTests {
    @Test func imageView() throws {
        let props = ImageProperties(
            url: BoundValue(literal: "https://example.com/img.png"),
            fit: .cover,
            variant: .header
        )
        let surface = SurfaceState(id: "test")
        let view = A2UIImageView(properties: props, surface: surface)
            
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        #expect(try view.inspect().find(ViewType.AsyncImage.self) != nil)
    }

    @Test func imageViewAvatar() throws {
        let props = ImageProperties(
            url: BoundValue(literal: "https://example.com/avatar.png"),
            fit: .cover,
            variant: .avatar
        )
        let surface = SurfaceState(id: "test")
        let view = A2UIImageView(properties: props, surface: surface)
            
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        #expect(try view.inspect().find(ViewType.AsyncImage.self) != nil)
    }
}
