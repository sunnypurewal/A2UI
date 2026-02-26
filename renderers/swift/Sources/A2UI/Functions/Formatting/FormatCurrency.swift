import Foundation

extension A2UIFunctionEvaluator {
    internal static func formatCurrency(args: [String: Any]) -> String {
        guard let value = (args["value"] as? Double) ?? (args["value"] as? Int).map(Double.init),
              let currencyCode = args["currency"] as? String else { return "" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        
        if let decimalsVal = args["decimals"] {
            let decimals = (decimalsVal as? Int) ?? Int(decimalsVal as? Double ?? 0)
            formatter.minimumFractionDigits = decimals
            formatter.maximumFractionDigits = decimals
        }
        
        if let grouping = args["grouping"] as? Bool {
            formatter.usesGroupingSeparator = grouping
        }
        
        return formatter.string(from: NSNumber(value: value)) ?? "\(currencyCode) \(value)"
    }
}
