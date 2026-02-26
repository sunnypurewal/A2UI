import Foundation

extension A2UIFunctionEvaluator {
    internal static func pluralize(value: Double, zero: String?, one: String?, other: String?) -> String {
        // This is a simplified version of CLDR pluralization
        // For English: 1 -> one, everything else -> other
        if value == 1 {
            return one ?? other ?? ""
        } else if value == 0 {
            return zero ?? other ?? ""
        } else {
            return other ?? ""
        }
    }
}
