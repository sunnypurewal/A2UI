import Foundation

extension A2UIFunctionEvaluator {
    internal static func pluralize(args: [String: Any]) -> String {
        guard let value = (args["value"] as? Double) ?? (args["value"] as? Int).map(Double.init) else { return "" }
        
        // This is a simplified version of CLDR pluralization
        // For English: 1 -> one, everything else -> other
        if value == 1 {
            return (args["one"] as? String) ?? (args["other"] as? String) ?? ""
        } else if value == 0 {
            return (args["zero"] as? String) ?? (args["other"] as? String) ?? ""
        } else {
            return (args["other"] as? String) ?? ""
        }
    }
}
