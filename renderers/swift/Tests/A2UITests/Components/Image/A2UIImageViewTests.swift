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
        let view = A2UIImageView(properties: props)
            .environment(surface)
            
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        XCTAssertNotNil(try view.inspect().view(A2UIImageView.self))
    }
}
