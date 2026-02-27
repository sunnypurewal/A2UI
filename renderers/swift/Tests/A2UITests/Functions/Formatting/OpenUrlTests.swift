import Foundation
import Testing
@testable import A2UI

@MainActor
struct OpenUrlTests {
    private let surface = SurfaceState(id: "test")

    @Test func openUrl() async {
        let mockOpener = MockURLOpener()
        let originalOpener = A2UIStandardFunctions.sharedURLOpener
        A2UIStandardFunctions.sharedURLOpener = mockOpener
        defer {
            A2UIStandardFunctions.sharedURLOpener = originalOpener
        }
        
        let validCall = FunctionCall(call: "openUrl", args: ["url": AnyCodable("https://example.com")])
        _ = A2UIStandardFunctions.evaluate(call: validCall, surface: surface)
        #expect(mockOpener.openedURL?.absoluteString == "https://example.com")

        let badCall = FunctionCall(call: "openUrl", args: ["url": AnyCodable("")])
        #expect(A2UIStandardFunctions.evaluate(call: badCall, surface: surface) == nil)
		#expect(mockOpener.openedURL?.absoluteString == "https://example.com") // not updated
        
        let invalidArgs = FunctionCall(call: "openUrl", args: ["url": AnyCodable(123)])
        #expect(A2UIStandardFunctions.evaluate(call: invalidArgs, surface: surface) == nil)
		#expect(mockOpener.openedURL?.absoluteString == "https://example.com") // not updated
    }
}

class MockURLOpener: NSObject, URLOpener {
    var openedURL: URL?
    func open(_ url: URL) {
        openedURL = url
    }
}
