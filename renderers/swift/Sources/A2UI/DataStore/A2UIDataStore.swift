import Foundation
import SwiftUI
import OSLog

/// The central store for all A2UI surfaces and their data.
@MainActor @Observable public class A2UIDataStore: NSObject, URLSessionDataDelegate, Sendable {
    /// A collection of active surfaces, keyed by their unique surfaceId.
    public var surfaces: [String: SurfaceState] = [:]
    
    private let parser = A2UIParser()
    private var streamRemainder = ""
	#if DEBUG
    private let log = OSLog(subsystem: "org.a2ui.renderer", category: "DataStore")
	#else
		private let log = OSLog.disabled
	#endif
    
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
            let _ = getOrCreateSurface(id: create.surfaceId)
            
            
        case .surfaceUpdate(let update):
            let surface = getOrCreateSurface(id: update.surfaceId)
            os_log("Surface update: %{public}@ (%d components)", log: log, type: .debug, update.surfaceId, update.components.count)
            surface.isReady = true
            os_log("Surface %{public}@ is now READY", log: log, type: .info, update.surfaceId)
            for component in update.components {
                surface.components[component.id] = component
            }
            // If no root set yet, try to determine it
            if surface.rootComponentId == nil {
                if update.components.contains(where: { $0.id == "root" }) {
                    surface.rootComponentId = "root"
                } else if let first = update.components.first {
                    // Fallback: use the first component as root if "root" isn't found
                    surface.rootComponentId = first.id
                    os_log("No 'root' component found, defaulting to first component: %{public}@", log: log, type: .info, first.id)
                }
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
        process(chunk: "
")
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
