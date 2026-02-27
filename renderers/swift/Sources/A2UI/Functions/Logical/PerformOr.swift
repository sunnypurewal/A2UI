import Foundation

extension A2UIStandardFunctions {
    static func performOr(values: [Bool]) -> Bool {
        return values.contains { $0 }
    }
}
