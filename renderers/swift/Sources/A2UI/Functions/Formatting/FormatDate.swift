import Foundation

extension A2UIStandardFunctions {
    internal static func formatDate(value: Any, format: String) -> String {
        let date: Date
        if let d = value as? Date {
            date = d
        } else if let s = value as? String {
            // Try ISO 8601
            let isoFormatter = ISO8601DateFormatter()
            if let d = isoFormatter.date(from: s) {
                date = d
            } else {
                // Try other common formats or return raw
                return s
            }
        } else if let d = value as? Double {
            // Assume seconds since 1970
            date = Date(timeIntervalSince1970: d)
        } else {
            return "\(value)"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
