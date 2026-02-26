import Foundation

extension A2UIFunctionEvaluator {
    internal static func performOr(values: [Bool]?) -> Bool {
        guard let values = values else { return false }
        return values.contains { $0 }
    }
}
