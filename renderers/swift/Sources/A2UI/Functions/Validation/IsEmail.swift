import Foundation

extension A2UIFunctionEvaluator {
    internal static func isEmail(args: [String: Any]) -> Bool {
        guard let value = args["value"] as? String else { return false }
        let pattern = #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: value.utf16.count)
        return regex?.firstMatch(in: value, options: [], range: range) != nil
    }
}
