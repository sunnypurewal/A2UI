import Foundation

extension A2UIFunctionEvaluator {
    internal static func performNot(value: Bool?) -> Bool {
        guard let value = value else { return false }
        return !value
    }
}
