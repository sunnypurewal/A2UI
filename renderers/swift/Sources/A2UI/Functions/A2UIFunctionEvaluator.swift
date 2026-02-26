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
}
