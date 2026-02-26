import Foundation

extension A2UIFunctionEvaluator {
    internal static func performAnd(values: [Bool]?) -> Bool {
        guard let values = values else { return false }
        return values.allSatisfy { $0 }
    }
}
