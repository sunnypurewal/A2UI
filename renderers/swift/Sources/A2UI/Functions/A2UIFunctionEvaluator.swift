import Foundation
import OSLog

@MainActor
public enum A2UIFunctionEvaluator {
    internal static let log = OSLog(subsystem: "org.a2ui.renderer", category: "FunctionEvaluator")

    public static func evaluate(call: FunctionCall, surface: SurfaceState) -> Any? {
        // First, resolve all arguments
        var resolvedArgs: [String: Any] = [:]
        for (key, value) in call.args {
            resolvedArgs[key] = resolveDynamicValue(value.value, surface: surface)
        }

        switch call.call {
        case "required":
            return isRequired(value: resolvedArgs["value"])
        case "regex":
            return matchesRegex(value: resolvedArgs["value"] as? String, pattern: resolvedArgs["pattern"] as? String)
        case "length":
            return checkLength(
                value: resolvedArgs["value"] as? String,
                min: asInt(resolvedArgs["min"]),
                max: asInt(resolvedArgs["max"])
            )
        case "numeric":
            return checkNumeric(
                value: resolvedArgs["value"],
                min: asDouble(resolvedArgs["min"]),
                max: asDouble(resolvedArgs["max"])
            )
        case "email":
            return isEmail(value: resolvedArgs["value"] as? String)
        case "formatString":
            return formatString(format: resolvedArgs["value"] as? String, surface: surface)
        case "formatNumber":
            return formatNumber(
                value: asDouble(resolvedArgs["value"]),
                decimals: asInt(resolvedArgs["decimals"]),
                grouping: resolvedArgs["grouping"] as? Bool
            )
        case "formatCurrency":
            return formatCurrency(
                value: asDouble(resolvedArgs["value"]),
                currency: resolvedArgs["currency"] as? String,
                decimals: asInt(resolvedArgs["decimals"]),
                grouping: resolvedArgs["grouping"] as? Bool
            )
        case "formatDate":
            return formatDate(value: resolvedArgs["value"], format: resolvedArgs["format"] as? String)
        case "pluralize":
            return pluralize(
                value: asDouble(resolvedArgs["value"]),
                zero: resolvedArgs["zero"] as? String,
                one: resolvedArgs["one"] as? String,
                other: resolvedArgs["other"] as? String
            )
        case "openUrl":
            openUrl(url: resolvedArgs["url"] as? String)
            return nil
        case "and":
            return performAnd(values: resolvedArgs["values"] as? [Bool])
        case "or":
            return performOr(values: resolvedArgs["values"] as? [Bool])
        case "not":
            return performNot(value: resolvedArgs["value"] as? Bool)
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
                let anyCodableArgs = args.mapValues { AnyCodable($0 as! Sendable) }
                let returnType = dict["returnType"] as? String
                let nestedCall = FunctionCall(call: callName, args: anyCodableArgs, returnType: returnType)
                return evaluate(call: nestedCall, surface: surface)
            }
        }

        // Otherwise, it's a literal
        return value
    }
}
