import Foundation

extension A2UIFunctionEvaluator {
    internal static func checkNumeric(value: Any?, min: Double?, max: Double?) -> Bool {
        let numericValue: Double?
        if let d = value as? Double {
            numericValue = d
        } else if let i = value as? Int {
            numericValue = Double(i)
        } else if let s = value as? String, let d = Double(s) {
            numericValue = d
        } else {
            numericValue = nil
        }

        guard let val = numericValue else { return false }

        if let min = min {
            if val < min { return false }
        }
        if let max = max {
            if val > max { return false }
        }
        return true
    }
}
