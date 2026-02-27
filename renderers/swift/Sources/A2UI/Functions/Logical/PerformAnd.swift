import Foundation

extension A2UIStandardFunctions {
    internal static func performAnd(values: [Bool]) -> Bool {
        return values.allSatisfy { $0 }
    }
}
