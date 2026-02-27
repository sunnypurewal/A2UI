import Foundation
import Testing
@testable import A2UI

@MainActor
struct OpenUrlTests {
    private let surface = SurfaceState(id: "test")

    @Test func openUrl() async {
        let badCall = FunctionCall(call: "openUrl", args: ["url": AnyCodable("")])
        #expect(A2UIStandardFunctions.evaluate(call: badCall, surface: surface) == nil)
        
        let invalidArgs = FunctionCall(call: "openUrl", args: ["url": AnyCodable(123)])
        #expect(A2UIStandardFunctions.evaluate(call: invalidArgs, surface: surface) == nil)
    }
}

extension A2UIStandardFunctions {
	fileprivate static var sharedURLOpener: URLOpener = MockURLOpener()
}
class MockURLOpener: NSObject, URLOpener {
	
	func open(_ url: URL) {
		
	}
}
