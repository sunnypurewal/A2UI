import Foundation

extension A2UIStandardFunctions {
    static func performAnd(values: [Bool]) -> Bool {
        return values.allSatisfy { $0 }
    }
}
