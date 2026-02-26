import Foundation

extension A2UIFunctionEvaluator {
    internal static func performAnd(values: [Bool]) -> Bool {
        return values.allSatisfy { $0 }
    }
}
