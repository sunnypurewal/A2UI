import Foundation

extension A2UIFunctionEvaluator {
    internal static func performOr(args: [String: Any]) -> Bool {
        guard let values = args["values"] as? [Bool] else { return false }
        return values.contains { $0 }
    }
}
