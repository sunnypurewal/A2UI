import Foundation

extension A2UIStandardFunctions {
    internal static func formatCurrency(value: Double, currency: String, decimals: Int?, grouping: Bool?) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        
        if let decimals = decimals {
            formatter.minimumFractionDigits = decimals
            formatter.maximumFractionDigits = decimals
        }
        
        if let grouping = grouping {
            formatter.usesGroupingSeparator = grouping
        }
        
        return formatter.string(from: NSNumber(value: value)) ?? "\(currency) \(value)"
    }
}
