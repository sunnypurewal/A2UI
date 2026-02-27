import Foundation

extension A2UIStandardFunctions {
    static func isRequired(value: Any) -> Bool {
        if let s = value as? String {
            return !s.isEmpty
        }
        if value is NSNull || value is JSONNull {
            return false
        }
        return true
    }
}
