import Foundation

extension A2UIStandardFunctions {
    internal static func checkNumeric(value: Double, min: Double?, max: Double?) -> Bool {
        if let min = min {
            if value < min { return false }
        }
        if let max = max {
            if value > max { return false }
        }
        return true
    }
}
