import Foundation

// Define a common interface for all platforms
@MainActor
protocol URLOpener: NSObject {
	func open(_ url: URL)
}

extension A2UIStandardFunctions {
	static func openUrl(url: String) {
		guard let url = URL(string: url) else { return }
		sharedURLOpener.open(url)
	}
}

// Implement open URL functionality for each platform
#if os(iOS)
import UIKit
extension A2UIStandardFunctions {
	fileprivate static var sharedURLOpener: URLOpener = UIApplication.shared
}

extension UIApplication: URLOpener {
	func open(_ url: URL) {
		self.open(url, options: [:], completionHandler: nil)
	}
}
#elseif os(macOS)
import AppKit
extension A2UIStandardFunctions {
	fileprivate static var sharedURLOpener: URLOpener = NSWorkspace.shared
}
@MainActor
extension NSWorkspace: URLOpener {
	func open(_ url: URL) {
		self.open(url, configuration: .init(), completionHandler: nil)
	}
}
#endif
