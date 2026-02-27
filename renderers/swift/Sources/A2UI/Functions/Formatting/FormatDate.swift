import Foundation
import DataDetection

extension A2UIStandardFunctions {
	internal static func formatDate(value: Any, format: String, timeZone: TimeZone = .autoupdatingCurrent, locale: Locale = .autoupdatingCurrent) -> String {
        let date: Date
        if let d = value as? Date {
            date = d
        } else if let s = value as? String {
            // Try ISO 8601
            let isoFormatter = ISO8601DateFormatter()
            if let d = isoFormatter.date(from: s) {
                date = d
            } else {
				if let detector = try? NSDataDetector(types: NSTextCheckingAllSystemTypes) {
					let matches = detector.matches(in: s, range: NSRange(location: 0, length: s.count))
					let dateMatches = matches.filter { $0.resultType == .date }
					if let firstDate = dateMatches.first?.date {
						date = firstDate
					} else {
						return s
					}
				} else {
					return s
				}
            }
        } else if let d = value as? Double {
            // Assume seconds since 1970
            date = Date(timeIntervalSince1970: d)
        } else {
            return "\(value)"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
		formatter.timeZone = timeZone
		formatter.locale = locale
        return formatter.string(from: date)
    }
}
