import Foundation
import OSLog

extension A2UIFunctionEvaluator {
    internal static func matchesRegex(value: String, pattern: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: value.utf16.count)
            return regex.firstMatch(in: value, options: [], range: range) != nil
        } catch {
            os_log("Invalid regex pattern: %{public}@", log: log, type: .error, pattern)
            return false
        }
    }
}
