import Foundation
import SwiftUI
import OSLog

/// The central store for all A2UI surfaces and their data.
@MainActor @Observable public class A2UIDataStore: NSObject, URLSessionDataDelegate, Sendable {
    /// A collection of active surfaces, keyed by their unique surfaceId.
    public var surfaces: [String: SurfaceState] = [:]
    
    private let parser = A2UIParser()
    private var streamRemainder = ""
    private let log = OSLog(subsystem: "org.a2ui.renderer", category: "DataStore")
    
    /// A callback for components to trigger actions that need to be sent back to the server.
    public var actionHandler: ((UserAction) -> Void)?
    
    /// A callback for the app layer to handle incoming messages (e.g. for chat history).
    public var messageHandler: ((A2UIMessage) -> Void)?
    
    /// A callback for the app layer to handle non-core application messages (e.g. "javascript", "text").
    public var appMessageHandler: ((String, [String: AnyCodable]) -> Void)?
    
    /// A callback for when the orchestrator sends a plain text message.
    public var onTextMessageReceived: ((String) -> Void)?
    
    /// A registry for custom component renderers.
    public var customRenderers: [String: @MainActor (ComponentInstance) -> AnyView] = [:]

    /// Whether to show debug borders around components.
    public var showDebugBorders: Bool = false

    public override init() {
        super.init()
    }

    /// Processes a single A2UIMessage and updates the relevant surface.
    public func process(message: A2UIMessage) {
        // First, notify the message handler
        messageHandler?(message)

        switch message {
        case .createSurface(let create):
            os_log("Create surface: %{public}@", log: log, type: .info, create.surfaceId)
            let surface = getOrCreateSurface(id: create.surfaceId)
            surface.isReady = true
            
        case .surfaceUpdate(let update):
            let surface = getOrCreateSurface(id: update.surfaceId)
            os_log("Surface update: %{public}@ (%d components)", log: log, type: .debug, update.surfaceId, update.components.count)
            surface.isReady = true
            for component in update.components {
                surface.components[component.id] = component
            }
            // If no root set yet, look for a component with id "root"
            if surface.rootComponentId == nil, update.components.contains(where: { $0.id == "root" }) {
                surface.rootComponentId = "root"
            }
            
        case .dataModelUpdate(let update):
            let surfaceId = update.surfaceId
            let surface = getOrCreateSurface(id: surfaceId)
            os_log("Data model update: %{public}@", log: log, type: .debug, surfaceId)

            let path = update.path ?? "/"
            if let value = update.value?.value {
                surface.setValue(at: path, value: value)
            }
            
        case .deleteSurface(let delete):
            os_log("Delete surface: %{public}@", log: log, type: .info, delete.surfaceId)
            surfaces.removeValue(forKey: delete.surfaceId)
            
        case .appMessage(let name, let data):
            os_log("Received application message: %{public}@", log: log, type: .info, name)
            if name == "text", let text = data["text"]?.value as? String {
                onTextMessageReceived?(text)
            }
            appMessageHandler?(name, data)
        }
    }

    public func process(chunk: String) {
        let messages = parser.parse(chunk: chunk, remainder: &streamRemainder)
        for message in messages {
            process(message: message)
        }
    }

    public func flush() {
        guard !streamRemainder.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        process(chunk: "\n")
    }

    private func getOrCreateSurface(id: String) -> SurfaceState {
        if let existing = surfaces[id] {
            return existing
        }
        let newSurface = SurfaceState(id: id)
        newSurface.customRenderers = self.customRenderers
        newSurface.actionHandler = { [weak self] action in
            self?.actionHandler?(action)
        }
        surfaces[id] = newSurface
        return newSurface
    }
}

/// Represents the live state of a single UI surface.
@MainActor @Observable public class SurfaceState: Identifiable, Sendable {
    public let id: String
    public var isReady: Bool = false
    public var rootComponentId: String?
    public var components: [String: ComponentInstance] = [:]
    public var dataModel: [String: Any] = [:]
    
    public var customRenderers: [String: @MainActor (ComponentInstance) -> AnyView] = [:]
    
    var actionHandler: ((UserAction) -> Void)?
    
    public init(id: String) {
        self.id = id
    }

    public var name: String? {
        return dataModel["surface_name"] as? String ?? id
    }

    public func resolve<T>(_ boundValue: BoundValue<T>) -> T? {
        if let path = boundValue.path {
            return getValue(at: path) as? T
        }
        return boundValue.literal
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
        guard let data = getValue(at: template.dataBinding) as? [Any] else {
            return []
        }
        
        var generatedIds: [String] = []
        for (index, _) in data.enumerated() {
            let virtualId = "\(template.componentId):\(template.dataBinding):\(index)"
            generatedIds.append(virtualId)
        }
        return generatedIds
    }
}
