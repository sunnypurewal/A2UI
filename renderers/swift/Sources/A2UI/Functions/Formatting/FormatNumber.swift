import Foundation

extension A2UIFunctionEvaluator {
    internal static func formatNumber(args: [String: Any]) -> String {
        guard let value = (args["value"] as? Double) ?? (args["value"] as? Int).map(Double.init) else { return "" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        if let decimalsVal = args["decimals"] {
            let decimals = (decimalsVal as? Int) ?? Int(decimalsVal as? Double ?? 0)
            formatter.minimumFractionDigits = decimals
            formatter.maximumFractionDigits = decimals
        }
        
        if let grouping = args["grouping"] as? Bool {
            formatter.usesGroupingSeparator = grouping
        } else {
            formatter.usesGroupingSeparator = true
        }
        
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
