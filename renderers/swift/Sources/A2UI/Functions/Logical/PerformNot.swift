import Foundation

extension A2UIFunctionEvaluator {
    internal static func performNot(args: [String: Any]) -> Bool {
        guard let value = args["value"] as? Bool else { return false }
        return !value
    }
}
