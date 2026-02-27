import Foundation
import SwiftUI
import OSLog

/// Represents the live state of a single UI surface.
@MainActor @Observable public class SurfaceState: Identifiable, Sendable {
    public let id: String
    public var isReady: Bool = false
    public var rootComponentId: String?
    public var components: [String: ComponentInstance] = [:]
    public var dataModel: [String: Any] = [:]
    public var validationErrors: [String: String] = [:]
    
    public var customRenderers: [String: @MainActor (ComponentInstance) -> AnyView] = [:]
    
    var actionHandler: ((UserAction) -> Void)?
    
    public init(id: String) {
        self.id = id
    }

    public var name: String? {
        return dataModel["surface_name"] as? String ?? id
    }

    public func resolve<T>(_ boundValue: BoundValue<T>?) -> T? {
        guard let boundValue = boundValue else { return nil }
        return resolve(boundValue)
    }

    public func resolve<T>(_ boundValue: BoundValue<T>) -> T? {
        if let functionCall = boundValue.functionCall {
            let result = A2UIFunctionEvaluator.evaluate(call: functionCall, surface: self)
            return convert(result)
        }
        
        if let path = boundValue.path {
            let value = getValue(at: path)
            return convert(value)
        }
        
        return boundValue.literal
    }

    private func convert<T>(_ value: Any?) -> T? {
        if value == nil || value is NSNull { return nil }
        
        // Special handling for String conversion
        if T.self == String.self {
            if let stringValue = value as? String {
                return stringValue as? T
            } else if let intValue = value as? Int {
                return String(intValue) as? T
            } else if let doubleValue = value as? Double {
                // Format appropriately, maybe avoid trailing zeros if it's an integer-like double
                return String(format: "%g", doubleValue) as? T
            } else if let boolValue = value as? Bool {
                return String(boolValue) as? T
            } else if value != nil {
                 return String(describing: value!) as? T
            }
        }
        
        if let tValue = value as? T {
            return tValue
        }
        
        // Numeric conversions
        if T.self == Double.self, let intValue = value as? Int {
            return Double(intValue) as? T
        }
        if T.self == Int.self, let doubleValue = value as? Double {
			return Int(doubleValue.rounded()) as? T
        }
        
        return nil
    }
    
    public func getValue(at path: String) -> Any? {
        let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        let normalizedPath = cleanPath.replacingOccurrences(of: ".", with: "/")
        let parts = normalizedPath.split(separator: "/").map(String.init)
        
        var current: Any? = dataModel
        for part in parts {
            if let dict = current as? [String: Any] {
                current = dict[part]
            } else if let array = current as? [Any], let index = Int(part), index < array.count {
                current = array[index]
            } else {
                return nil
            }
        }
        return current
    }

    public func runChecks(for componentId: String) {
        guard let instance = components[componentId], let checks = instance.checks else {
            validationErrors.removeValue(forKey: componentId)
            return
        }
        
        if let error = errorMessage(surface: self, checks: checks) {
            validationErrors[componentId] = error
        } else {
            validationErrors.removeValue(forKey: componentId)
        }
    }

    public func setValue(at path: String, value: Any) {
        let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        let normalizedPath = cleanPath.replacingOccurrences(of: ".", with: "/")
        let parts = normalizedPath.split(separator: "/").map(String.init)
        let normalizedValue = normalize(value: value)
        
        guard !parts.isEmpty else {
            if let dict = normalizedValue as? [String: Any] {
                mergeRaw(dict, into: &dataModel)
            }
            return
        }

        func update(dict: [String: Any], parts: [String], newValue: Any) -> [String: Any] {
            var newDict = dict
            let key = parts[0]
            
            if parts.count == 1 {
                newDict[key] = newValue
            } else {
                let subDict = (dict[key] as? [String: Any]) ?? [:]
                newDict[key] = update(dict: subDict, parts: Array(parts.dropFirst()), newValue: normalize(value: newValue))
            }
            return newDict
        }

        dataModel = update(dict: dataModel, parts: parts, newValue: normalizedValue)
    }

    private func normalize(value: Any) -> Any {
        if value is JSONNull {
            return NSNull()
        }
        
        if let dict = value as? [String: Sendable] {
            var result: [String: Any] = [:]
            for (key, entry) in dict {
                result[key] = normalize(value: entry)
            }
            return result
        }

        if let array = value as? [Sendable] {
            return array.map { normalize(value: $0) }
        }

        return value
    }

    public func mergeRaw(_ source: [String: Any], into destination: inout [String: Any]) {
        for (key, value) in source {
            if let sourceDict = value as? [String: Any],
               let destDict = destination[key] as? [String: Any] {
                var newDest = destDict
                mergeRaw(sourceDict, into: &newDest)
                destination[key] = newDest
            } else {
                destination[key] = value
            }
        }
    }

    public func trigger(action: Action) {
        let userAction = UserAction(surfaceId: id, action: action)
        actionHandler?(userAction)
    }
    
    public func expandTemplate(template: Template) -> [String] {
        guard let data = getValue(at: template.path) as? [Any] else {
            return []
        }
        
        var generatedIds: [String] = []
        for (index, _) in data.enumerated() {
            let virtualId = "\(template.componentId):\(template.path):\(index)"
            generatedIds.append(virtualId)
        }
        return generatedIds
    }
}
