import Foundation

extension A2UIFunctionEvaluator {
    internal static func performAnd(args: [String: Any]) -> Bool {
        guard let values = args["values"] as? [Bool] else { return false }
        return values.allSatisfy { $0 }
    }
}
