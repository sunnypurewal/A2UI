import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension A2UIFunctionEvaluator {
    internal static func openUrl(url: String) {
        guard let url = URL(string: url) else { return }
        
        #if os(iOS)
        UIApplication.shared.open(url)
        #elseif os(macOS)
        NSWorkspace.shared.open(url)
        #endif
    }
}
