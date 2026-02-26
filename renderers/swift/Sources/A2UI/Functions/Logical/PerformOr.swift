import Foundation

extension A2UIFunctionEvaluator {
    internal static func performOr(values: [Bool]) -> Bool {
        return values.contains { $0 }
    }
}
