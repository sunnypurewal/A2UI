import Foundation

extension A2UIFunctionEvaluator {
    internal static func checkLength(args: [String: Any]) -> Bool {
        guard let value = args["value"] as? String else { return false }
        let length = value.count
        
        if let minVal = args["min"] {
            let min = (minVal as? Int) ?? Int(minVal as? Double ?? 0)
            if length < min { return false }
        }
        if let maxVal = args["max"] {
            let max = (maxVal as? Int) ?? Int(maxVal as? Double ?? Double.greatestFiniteMagnitude)
            if length > max { return false }
        }
        return true
    }
}
