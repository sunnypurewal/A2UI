import Foundation

extension A2UIStandardFunctions {
    internal static func formatString(format: String, surface: SurfaceState) -> String {
        // Simple interpolation for ${/path} or ${expression}
        // This is a basic implementation of the description in basic_catalog.json
        var result = format
        let pattern = #"\$\{([^}]+)\}"#
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
                    replacement = "${\(expression)}"
                }
                
                if let fullR = Range(fullRange, in: result) {
                    result.replaceSubrange(fullR, with: replacement)
                }
            }
        }
        
        return result
    }
}
