import Foundation

extension A2UIFunctionEvaluator {
    internal static func checkNumeric(args: [String: Any]) -> Bool {
        guard let value = (args["value"] as? Double) ?? (args["value"] as? Int).map(Double.init) else {
            // Try to parse from string if it's a string
            if let s = args["value"] as? String, let d = Double(s) {
                return checkNumeric(value: d, args: args)
            }
            return false
        }
        return checkNumeric(value: value, args: args)
    }

    private static func checkNumeric(value: Double, args: [String: Any]) -> Bool {
        if let minVal = args["min"] {
            let min = (minVal as? Double) ?? (minVal as? Int).map(Double.init) ?? -Double.greatestFiniteMagnitude
            if value < min { return false }
        }
        if let maxVal = args["max"] {
            let max = (maxVal as? Double) ?? (maxVal as? Int).map(Double.init) ?? Double.greatestFiniteMagnitude
            if value > max { return false }
        }
        return true
    }
}
