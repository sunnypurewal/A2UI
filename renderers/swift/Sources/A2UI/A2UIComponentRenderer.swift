import SwiftUI

/// A internal view that resolves a component ID and renders the appropriate SwiftUI view.
struct A2UIComponentRenderer: View {
    @Environment(A2UIDataStore.self) var dataStore
    @Environment(SurfaceState.self) var surface
    let componentId: String

    var body: some View {
        let (instance, contextSurface) = resolveInstanceAndContext()
        
        if let instance = instance {
            render(instance: instance)
                .environment(contextSurface ?? surface)
        } else {
            // Fallback for missing components to help debugging
            Text("Missing: \(componentId)")
                .foregroundColor(.red)
                .font(.caption)
        }
    }
    
    private func resolveInstanceAndContext() -> (instance: ComponentInstance?, contextSurface: SurfaceState?) {
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
            return (surface.components[componentId], nil)
        }
    }

    @ViewBuilder
    private func render(instance: ComponentInstance) -> some View {
        let content = Group {
            // Check for custom registered components first
            if let customRenderer = surface.customRenderers[instance.componentTypeName] {
                customRenderer(instance)
            } else {
                renderStandard(instance: instance)
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

    @ViewBuilder
    private func renderStandard(instance: ComponentInstance) -> some View {
        switch instance.component {
        case .text(let props):
            A2UITextView(properties: props)
        case .button(let props):
            A2UIButtonView(properties: props)
        case .row(let props):
            A2UIRowView(properties: props)
        case .column(let props):
            A2UIColumnView(properties: props)
        case .card(let props):
            A2UICardView(properties: props)
        case .image(let props):
            A2UIImageView(properties: props)
        case .icon(let props):
            A2UIIconView(properties: props)
        case .video(let props):
            A2UIVideoView(properties: props)
        case .audioPlayer(let props):
            A2UIAudioPlayerView(properties: props)
        case .divider:
            A2UIDividerView()
        case .list(let props):
            A2UIListView(properties: props)
        case .tabs(let props):
            A2UITabsView(properties: props)
        case .modal(let props):
            A2UIModalView(properties: props)
        case .textField(let props):
            A2UITextFieldView(properties: props)
        case .checkBox(let props):
            A2UICheckBoxView(properties: props)
        case .dateTimeInput(let props):
            A2UIDateTimeInputView(properties: props)
        case .choicePicker(let props):
            A2UIChoicePickerView(properties: props)
        case .slider(let props):
            A2UISliderView(properties: props)
        case .custom:
            // Custom components should have been handled by the customRenderer check.
            // If we're here, no custom renderer was found.
            Text("Unknown Custom Component: \(instance.componentTypeName)")
                .foregroundColor(.red)
        }
    }
}

extension ComponentInstance {
    var componentTypeName: String {
        component.typeName
    }
}
