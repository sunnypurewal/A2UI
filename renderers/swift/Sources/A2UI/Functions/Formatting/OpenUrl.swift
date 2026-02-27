import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension A2UIStandardFunctions {
    internal static func openUrl(url: String) {
        guard let url = URL(string: url) else { return }
        
        #if os(iOS)
        UIApplication.shared.open(url)
        #elseif os(macOS)
        NSWorkspace.shared.open(url)
        #endif
    }
}

protocol URLOpener: NSObject {
	func open(_ url: URL)
}
#if os(iOS)
extension UIApplication: URLOpener {
//	func open(_ url: URL) {
//		self.open
//	}
}
#elseif os(macOS)
extension NSWorkspace: URLOpener {}
#endif
