import Foundation

extension A2UIFunctionEvaluator {
    internal static func formatNumber(value: Double?, decimals: Int?, grouping: Bool?) -> String {
        guard let value = value else { return "" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        if let decimals = decimals {
            formatter.minimumFractionDigits = decimals
            formatter.maximumFractionDigits = decimals
        }
        
        if let grouping = grouping {
            formatter.usesGroupingSeparator = grouping
        } else {
            formatter.usesGroupingSeparator = true
        }
        
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
