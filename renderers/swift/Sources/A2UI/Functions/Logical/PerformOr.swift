import Foundation

extension A2UIStandardFunctions {
    internal static func performOr(values: [Bool]) -> Bool {
        return values.contains { $0 }
    }
}
