import Foundation

extension A2UIFunctionEvaluator {
    internal static func checkLength(value: String?, min: Int?, max: Int?) -> Bool {
        guard let value = value else { return false }
        let length = value.count
        
        if let min = min {
            if length < min { return false }
        }
        if let max = max {
            if length > max { return false }
        }
        return true
    }
}
