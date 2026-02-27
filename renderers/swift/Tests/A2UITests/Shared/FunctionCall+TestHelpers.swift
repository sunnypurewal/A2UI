import Foundation
@testable import A2UI

extension FunctionCall {
    static func required(value: Sendable?) -> FunctionCall {
        FunctionCall(call: "required", args: ["value": AnyCodable(value)])
    }

    static func regex(value: Sendable, pattern: Sendable) -> FunctionCall {
        FunctionCall(call: "regex", args: ["value": AnyCodable(value), "pattern": AnyCodable(pattern)])
    }

    static func length(value: Sendable, min: Sendable? = nil, max: Sendable? = nil) -> FunctionCall {
        var args: [String: AnyCodable] = ["value": AnyCodable(value)]
        if let min { args["min"] = AnyCodable(min) }
        if let max { args["max"] = AnyCodable(max) }
        return FunctionCall(call: "length", args: args)
    }

    static func numeric(value: Sendable, min: Sendable? = nil, max: Sendable? = nil) -> FunctionCall {
        var args: [String: AnyCodable] = ["value": AnyCodable(value)]
        if let min { args["min"] = AnyCodable(min) }
        if let max { args["max"] = AnyCodable(max) }
        return FunctionCall(call: "numeric", args: args)
    }

    static func email(value: Sendable) -> FunctionCall {
        FunctionCall(call: "email", args: ["value": AnyCodable(value)])
    }

    static func formatString(value: Sendable) -> FunctionCall {
        FunctionCall(call: "formatString", args: ["value": AnyCodable(value)])
    }

    static func formatNumber(value: Sendable, decimals: Sendable? = nil, grouping: Sendable? = nil) -> FunctionCall {
        var args: [String: AnyCodable] = ["value": AnyCodable(value)]
        if let decimals { args["decimals"] = AnyCodable(decimals) }
        if let grouping { args["grouping"] = AnyCodable(grouping) }
        return FunctionCall(call: "formatNumber", args: args)
    }

    static func formatCurrency(value: Sendable, currency: Sendable) -> FunctionCall {
        FunctionCall(call: "formatCurrency", args: ["value": AnyCodable(value), "currency": AnyCodable(currency)])
    }

    static func formatDate(value: Sendable, format: Sendable) -> FunctionCall {
        FunctionCall(call: "formatDate", args: ["value": AnyCodable(value), "format": AnyCodable(format)])
    }

    static func pluralize(value: Sendable, zero: Sendable? = nil, one: Sendable? = nil, two: Sendable? = nil, other: Sendable) -> FunctionCall {
        var args: [String: AnyCodable] = ["value": AnyCodable(value), "other": AnyCodable(other)]
        if let zero { args["zero"] = AnyCodable(zero) }
        if let one { args["one"] = AnyCodable(one) }
        if let two { args["two"] = AnyCodable(two) }
        return FunctionCall(call: "pluralize", args: args)
    }

    static func and(values: Sendable) -> FunctionCall {
        FunctionCall(call: "and", args: ["values": AnyCodable(values)])
    }

    static func or(values: Sendable) -> FunctionCall {
        FunctionCall(call: "or", args: ["values": AnyCodable(values)])
    }

    static func not(value: Sendable) -> FunctionCall {
        FunctionCall(call: "not", args: ["value": AnyCodable(value)])
    }
    
    static func formatCurrency(value: Sendable, currency: Sendable, decimals: Int, grouping: Bool) -> FunctionCall {
        FunctionCall(call: "formatCurrency", args: [
            "value": AnyCodable(value),
            "currency": AnyCodable(currency),
            "decimals": AnyCodable(decimals),
            "grouping": AnyCodable(grouping)
        ])
    }
}
