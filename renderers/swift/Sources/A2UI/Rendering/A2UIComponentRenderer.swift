import SwiftUI
import OSLog

/// A internal view that resolves a component ID and renders the appropriate SwiftUI view.
struct A2UIComponentRenderer: View {
    @Environment(A2UIDataStore.self) var dataStore
    @Environment(SurfaceState.self) var surface
    let componentId: String
    let surfaceOverride: SurfaceState?
	#if DEBUG
    private let log = OSLog(subsystem: "org.a2ui.renderer", category: "ComponentRenderer")
	#else
	private let log = OSLog.disabled
	#endif

    init(componentId: String, surface: SurfaceState? = nil) {
        self.componentId = componentId
        self.surfaceOverride = surface
    }
    
    private var activeSurface: SurfaceState? {
        surfaceOverride ?? surface
    }

    var body: some View {
        Group {
            if let surface = activeSurface {
                renderContent(surface: surface)
            } else {
                Text("Error: No SurfaceState available").foregroundColor(.red)
            }
        }
    }
    
    @ViewBuilder
    private func renderContent(surface: SurfaceState) -> some View {
        let (instance, contextSurface) = resolveInstanceAndContext(surface: surface)
        
        if let instance = instance {
            let _ = os_log("Rendering component: %{public}@ (%{public}@)", log: log, type: .debug, componentId, instance.componentTypeName)
            render(instance: instance, surface: surface)
                .environment(contextSurface ?? surface)
        } else {
            let _ = os_log("Missing component: %{public}@", log: log, type: .error, componentId)
            // Fallback for missing components to help debugging
            Text("Missing: \(componentId)")
                .foregroundColor(.white)
                .padding(4)
                .background(Color.red)
                .font(.caption)
        }
    }
    
    private func resolveInstanceAndContext(surface: SurfaceState) -> (instance: ComponentInstance?, contextSurface: SurfaceState?) {
        let virtualIdParts = componentId.split(separator: ":")

        // Check if it's a virtual ID from a template: "templateId:dataBinding:index"
        if virtualIdParts.count == 3 {
            let baseId = String(virtualIdParts[0])
            let dataBinding = String(virtualIdParts[1])
            let indexStr = String(virtualIdParts[2])

            guard let instance = surface.components[baseId], let index = Int(indexStr) else {
                return (nil, nil)
            }

            // The data for the specific item in the array
            let itemPath = "\(dataBinding)/\(index)"
            if let itemData = surface.getValue(at: itemPath) as? [String: Any] {
                // This is a contextual surface state scoped to the item's data.
                let contextualSurface = SurfaceState(id: surface.id)
                contextualSurface.dataModel = itemData
                // Carry over the other essential properties from the main surface.
                contextualSurface.components = surface.components
                contextualSurface.customRenderers = surface.customRenderers
                contextualSurface.actionHandler = surface.actionHandler
                
                return (instance, contextualSurface)
            }
            
            // Return base instance but no special context if data is missing
            return (instance, nil)

        } else {
            // This is a regular component, not part of a template.
            // Return the component instance and no special context surface.
            if let component = surface.components[componentId] {
                return (component, nil)
            } else {
                os_log("Component not found in surface: %{public}@", log: log, type: .error, componentId)
                return (nil, nil)
            }
        }
    }

    @ViewBuilder
    private func render(instance: ComponentInstance, surface: SurfaceState) -> some View {
        let content = Group {
            // Check for custom registered components first
            if let customRenderer = surface.customRenderers[instance.componentTypeName] {
                customRenderer(instance)
            } else {
                A2UIStandardComponentView(instance: instance)
            }
        }
        
        if dataStore.showDebugBorders {
            content
                .border(debugColor(for: instance.componentTypeName), width: 1)
        } else {
            content
        }
    }

    private func debugColor(for typeName: String) -> Color {
        switch typeName {
        case "Column": return .blue
        case "Row": return .green
        case "Card": return .purple
        case "Text": return .red
        case "Button": return .orange
        default: return .gray
        }
    }
}
