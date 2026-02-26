import Foundation

extension A2UIFunctionEvaluator {
    internal static func isRequired(args: [String: Any]) -> Bool {
        guard let value = args["value"] else { return false }
        if let s = value as? String {
            return !s.isEmpty
        }
        if value is NSNull || value is JSONNull {
            return false
        }
        return true
    }
}
