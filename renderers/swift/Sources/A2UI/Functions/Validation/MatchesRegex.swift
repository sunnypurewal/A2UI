import Foundation

extension A2UIStandardFunctions {
    static func matchesRegex(value: String, pattern: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: value.utf16.count)
            return regex.firstMatch(in: value, options: [], range: range) != nil
        } catch {
            A2UILogger.error("Invalid regex pattern: \(pattern)")
            return false
        }
    }
}
