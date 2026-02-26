import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension A2UIFunctionEvaluator {
    internal static func openUrl(args: [String: Any]) {
        guard let urlString = args["url"] as? String,
              let url = URL(string: urlString) else { return }
        
        #if os(iOS)
        UIApplication.shared.open(url)
        #elseif os(macOS)
        NSWorkspace.shared.open(url)
        #endif
    }
}
