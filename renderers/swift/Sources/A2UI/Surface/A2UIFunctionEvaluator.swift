import Foundation
import OSLog
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@MainActor
public enum A2UIFunctionEvaluator {
    private static let log = OSLog(subsystem: "org.a2ui.renderer", category: "FunctionEvaluator")

    public static func evaluate(call: FunctionCall, surface: SurfaceState) -> Any? {
        // First, resolve all arguments
        var resolvedArgs: [String: Any] = [:]
        for (key, value) in call.args {
            resolvedArgs[key] = resolveDynamicValue(value.value, surface: surface)
        }

        switch call.call {
        case "required":
            return isRequired(args: resolvedArgs)
        case "regex":
            return matchesRegex(args: resolvedArgs)
        case "length":
            return checkLength(args: resolvedArgs)
        case "numeric":
            return checkNumeric(args: resolvedArgs)
        case "email":
            return isEmail(args: resolvedArgs)
        case "formatString":
            return formatString(args: resolvedArgs, surface: surface)
        case "formatNumber":
            return formatNumber(args: resolvedArgs)
        case "formatCurrency":
            return formatCurrency(args: resolvedArgs)
        case "formatDate":
            return formatDate(args: resolvedArgs)
        case "pluralize":
            return pluralize(args: resolvedArgs)
        case "openUrl":
            openUrl(args: resolvedArgs)
            return nil
        case "and":
            return performAnd(args: resolvedArgs)
        case "or":
            return performOr(args: resolvedArgs)
        case "not":
            return performNot(args: resolvedArgs)
        default:
            os_log("Unknown function call: %{public}@", log: log, type: .error, call.call)
            return nil
        }
    }

    public static func resolveDynamicValue(_ value: Any?, surface: SurfaceState) -> Any? {
        guard let value = value else { return nil }

        // If it's a dictionary, it might be a DataBinding or a FunctionCall
        if let dict = value as? [String: Any] {
            if let path = dict["path"] as? String {
                // It's a DataBinding
                return surface.getValue(at: path)
            } else if let callName = dict["call"] as? String {
                // It's a FunctionCall
                // We need to reconstruct the FunctionCall object or evaluate it directly
                let args = dict["args"] as? [String: Any] ?? [:]
                let anyCodableArgs = args.mapValues { AnyCodable($0 as! Sendable) }
                let returnType = dict["returnType"] as? String
                let nestedCall = FunctionCall(call: callName, args: anyCodableArgs, returnType: returnType)
                return evaluate(call: nestedCall, surface: surface)
            }
        }

        // Otherwise, it's a literal
        return value
    }

    // MARK: - Validation Functions

    private static func isRequired(args: [String: Any]) -> Bool {
        guard let value = args["value"] else { return false }
        if let s = value as? String {
            return !s.isEmpty
        }
        if value is NSNull {
            return false
        }
        return true
    }

    private static func matchesRegex(args: [String: Any]) -> Bool {
        guard let value = args["value"] as? String,
              let pattern = args["pattern"] as? String else { return false }
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: value.utf16.count)
            return regex.firstMatch(in: value, options: [], range: range) != nil
        } catch {
            os_log("Invalid regex pattern: %{public}@", log: log, type: .error, pattern)
            return false
        }
    }

    private static func checkLength(args: [String: Any]) -> Bool {
        guard let value = args["value"] as? String else { return false }
        let length = value.count
        
        if let min = args["min"] as? Int, length < min {
            return false
        }
        if let max = args["max"] as? Int, length > max {
            return false
        }
        return true
    }

    private static func checkNumeric(args: [String: Any]) -> Bool {
        guard let value = args["value"] as? Double else {
            // Try to parse from string if it's a string
            if let s = args["value"] as? String, let d = Double(s) {
                return checkNumeric(value: d, args: args)
            }
            return false
        }
        return checkNumeric(value: value, args: args)
    }

    private static func checkNumeric(value: Double, args: [String: Any]) -> Bool {
        if let min = args["min"] as? Double, value < min {
            return false
        }
        if let max = args["max"] as? Double, value > max {
            return false
        }
        return true
    }

    private static func isEmail(args: [String: Any]) -> Bool {
        guard let value = args["value"] as? String else { return false }
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: value.utf16.count)
        return regex?.firstMatch(in: value, options: [], range: range) != nil
    }

    // MARK: - Formatting Functions

    private static func formatString(args: [String: Any], surface: SurfaceState) -> String {
        guard let format = args["value"] as? String else { return "" }
        
        // Simple interpolation for ${/path} or ${expression}
        // This is a basic implementation of the description in basic_catalog.json
        var result = format
        let pattern = "\$\{([^}]+)\}"
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(in: format, options: [], range: NSRange(location: 0, length: format.utf16.count))
        
        for match in (matches ?? []).reversed() {
            let fullRange = match.range
            let expressionRange = match.range(at: 1)
            if let r = Range(expressionRange, in: format) {
                let expression = String(format[r])
                let replacement: String
                
                if expression.hasPrefix("/") {
                    // It's a path
                    if let val = surface.getValue(at: expression) {
                        replacement = "\(val)"
                    } else {
                        replacement = ""
                    }
                } else {
                    // For now, only simple paths are supported in formatString interpolation
                    // In a full implementation, we'd parse and evaluate expressions here
                    replacement = "$\{\(expression)\}"
                }
                
                if let fullR = Range(fullRange, in: result) {
                    result.replaceSubrange(fullR, with: replacement)
                }
            }
        }
        
        return result
    }

    private static func formatNumber(args: [String: Any]) -> String {
        guard let value = args["value"] as? Double else { return "" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        if let decimals = args["decimals"] as? Int {
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

    private static func formatCurrency(args: [String: Any]) -> String {
        guard let value = args["value"] as? Double,
              let currencyCode = args["currency"] as? String else { return "" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        
        if let decimals = args["decimals"] as? Int {
            formatter.minimumFractionDigits = decimals
            formatter.maximumFractionDigits = decimals
        }
        
        if let grouping = args["grouping"] as? Bool {
            formatter.usesGroupingSeparator = grouping
        }
        
        return formatter.string(from: NSNumber(value: value)) ?? "\(currencyCode) \(value)"
    }

    private static func formatDate(args: [String: Any]) -> String {
        guard let value = args["value"],
              let format = args["format"] as? String else { return "" }
        
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

    private static func pluralize(args: [String: Any]) -> String {
        guard let value = args["value"] as? Double else { return "" }
        
        // This is a simplified version of CLDR pluralization
        // For English: 1 -> one, everything else -> other
        if value == 1 {
            return (args["one"] as? String) ?? (args["other"] as? String) ?? ""
        } else if value == 0 {
            return (args["zero"] as? String) ?? (args["other"] as? String) ?? ""
        } else {
            return (args["other"] as? String) ?? ""
        }
    }

    private static func openUrl(args: [String: Any]) {
        guard let urlString = args["url"] as? String,
              let url = URL(string: urlString) else { return }
        
        #if os(iOS)
        UIApplication.shared.open(url)
        #elseif os(macOS)
        NSWorkspace.shared.open(url)
        #endif
    }

    // MARK: - Logical Functions

    private static func performAnd(args: [String: Any]) -> Bool {
        guard let values = args["values"] as? [Bool] else { return false }
        return values.allSatisfy { $0 }
    }

    private static func performOr(args: [String: Any]) -> Bool {
        guard let values = args["values"] as? [Bool] else { return false }
        return values.contains { $0 }
    }

    private static func performNot(args: [String: Any]) -> Bool {
        guard let value = args["value"] as? Bool else { return false }
        return !value
    }
}
