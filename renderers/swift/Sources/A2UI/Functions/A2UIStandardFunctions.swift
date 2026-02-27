import Foundation
import OSLog

@MainActor
public enum A2UIStandardFunctions {
    internal static let log = OSLog(subsystem: "org.a2ui.renderer", category: "FunctionEvaluator")

    public static func evaluate(call: FunctionCall, surface: SurfaceState) -> Any? {
        // First, resolve all arguments
        var resolvedArgs: [String: Any] = [:]
        for (key, value) in call.args {
            resolvedArgs[key] = resolveDynamicValue(value.value, surface: surface)
        }

        switch call.call {
        case "required":
            guard let val = resolvedArgs["value"] else { return false }
            return isRequired(value: val)
        case "regex":
            guard let val = resolvedArgs["value"] as? String,
                  let pattern = resolvedArgs["pattern"] as? String else { return false }
            return matchesRegex(value: val, pattern: pattern)
        case "length":
            guard let val = resolvedArgs["value"] as? String,
                  (asInt(resolvedArgs["min"]) != nil || asInt(resolvedArgs["max"]) != nil) else { return false }
            return checkLength(
                value: val,
                min: asInt(resolvedArgs["min"]),
                max: asInt(resolvedArgs["max"])
            )
        case "numeric":
            guard let val = asDouble(resolvedArgs["value"]),
                  (asDouble(resolvedArgs["min"]) != nil || asDouble(resolvedArgs["max"]) != nil) else { return false }
            return checkNumeric(
                value: val,
                min: asDouble(resolvedArgs["min"]),
                max: asDouble(resolvedArgs["max"])
            )
        case "email":
            guard let val = resolvedArgs["value"] as? String else { return false }
            return isEmail(value: val)
        case "formatString":
            guard let format = resolvedArgs["value"] as? String else { return "" }
            return formatString(format: format, surface: surface)
        case "formatNumber":
            guard let val = asDouble(resolvedArgs["value"]) else { return "" }
            return formatNumber(
                value: val,
                decimals: asInt(resolvedArgs["decimals"]),
                grouping: resolvedArgs["grouping"] as? Bool
            )
        case "formatCurrency":
            guard let val = asDouble(resolvedArgs["value"]),
                  let currency = resolvedArgs["currency"] as? String else { return "" }
            return formatCurrency(
                value: val,
                currency: currency,
                decimals: asInt(resolvedArgs["decimals"]),
                grouping: resolvedArgs["grouping"] as? Bool
            )
        case "formatDate":
            guard let val = resolvedArgs["value"],
                  let format = resolvedArgs["format"] as? String else { return "" }
            return formatDate(value: val, format: format)
        case "pluralize":
            guard let val = asDouble(resolvedArgs["value"]),
                  let other = resolvedArgs["other"] as? String else { return "" }
            return pluralize(
                value: val,
                zero: resolvedArgs["zero"] as? String,
                one: resolvedArgs["one"] as? String,
                two: resolvedArgs["two"] as? String,
                few: resolvedArgs["few"] as? String,
                many: resolvedArgs["many"] as? String,
                other: other
            )
        case "openUrl":
            guard let url = resolvedArgs["url"] as? String else { return nil }
            openUrl(url: url)
            return nil
        case "and":
            guard let values = resolvedArgs["values"] as? [Bool], values.count >= 2 else { return false }
            return performAnd(values: values)
        case "or":
            guard let values = resolvedArgs["values"] as? [Bool], values.count >= 2 else { return false }
            return performOr(values: values)
        case "not":
            guard let value = resolvedArgs["value"] as? Bool else { return false }
            return performNot(value: value)
        default:
            os_log("Unknown function call: %{public}@", log: log, type: .error, call.call)
            return nil
        }
    }

    private static func asInt(_ value: Any?) -> Int? {
        if let i = value as? Int { return i }
        if let d = value as? Double { return Int(d) }
        if let s = value as? String { return Int(s) }
        return nil
    }

    private static func asDouble(_ value: Any?) -> Double? {
        if let d = value as? Double { return d }
        if let i = value as? Int { return Double(i) }
        if let s = value as? String { return Double(s) }
        return nil
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
                let anyCodableArgs = args.mapValues { AnyCodable(makeSendable($0)) }
                let returnType = dict["returnType"] as? String
                let nestedCall = FunctionCall(call: callName, args: anyCodableArgs, returnType: returnType)
                return evaluate(call: nestedCall, surface: surface)
            }
        } else if let array = value as? [Any] {
            // Handle lists of DynamicValues (like in 'and'/'or' functions)
            return array.map { resolveDynamicValue($0, surface: surface) }
        }

        // Otherwise, it's a literal
        return value
    }

    /// Recursively converts Any values (like [String: Any] or [Any]) into Sendable existentials.
    private static func makeSendable(_ value: Any) -> Sendable {
        if let dict = value as? [String: Any] {
            return dict.mapValues { makeSendable($0) }
        }
        if let array = value as? [Any] {
            return array.map { makeSendable($0) }
        }
        
        // Marker protocols like Sendable cannot be used with 'as?'.
        // We handle common JSON-compatible Sendable types explicitly.
        if let s = value as? String { return s }
        if let i = value as? Int { return i }
        if let d = value as? Double { return d }
        if let b = value as? Bool { return b }
        if let date = value as? Date { return date }
        if let null = value as? JSONNull { return null }
        if value is NSNull { return JSONNull() }
        
        // Default fallback: if we can't guarantee Sendability for a type, we use JSONNull.
        return JSONNull()
    }
}
