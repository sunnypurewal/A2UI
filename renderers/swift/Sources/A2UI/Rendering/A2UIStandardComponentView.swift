import SwiftUI

/// A view that maps a standard A2UI component instance to its SwiftUI implementation.
struct A2UIStandardComponentView: View {
    @Environment(SurfaceState.self) var surfaceEnv: SurfaceState?
    var surface: SurfaceState?
    let instance: ComponentInstance
    
    private var activeSurface: SurfaceState? { surface ?? surfaceEnv }

    var body: some View {
        switch instance.component {
        case .text(let props):
            A2UITextView(surface: activeSurface, properties: props)
        case .button(let props):
            A2UIButtonView(id: instance.id, properties: props, checks: instance.checks, surface: activeSurface)
        case .row(let props):
            A2UIRowView(properties: props, surface: activeSurface)
        case .column(let props):
            A2UIColumnView(properties: props, surface: activeSurface)
        case .card(let props):
            A2UICardView(properties: props)
        case .image(let props):
            A2UIImageView(properties: props)
        case .icon(let props):
            A2UIIconView(properties: props, surface: activeSurface)
        case .video(let props):
            A2UIVideoView(properties: props)
        case .audioPlayer(let props):
            A2UIAudioPlayerView(properties: props)
        case .divider(let props):
            A2UIDividerView(surface: activeSurface, properties: props)
        case .list(let props):
            A2UIListView(properties: props, surface: activeSurface)
        case .tabs(let props):
            A2UITabsView(properties: props)
        case .modal(let props):
            A2UIModalView(properties: props)
        case .textField(let props):
            A2UITextFieldView(id: instance.id, properties: props, surface: activeSurface)
        case .checkBox(let props):
            A2UICheckBoxView(id: instance.id, properties: props)
        case .dateTimeInput(let props):
            A2UIDateTimeInputView(id: instance.id, properties: props, surface: activeSurface)
        case .choicePicker(let props):
            A2UIChoicePickerView(id: instance.id, properties: props, surface: activeSurface)
        case .slider(let props):
            A2UISliderView(id: instance.id, properties: props)
        case .custom:
            // Custom components should have been handled by the customRenderer check in A2UIComponentRenderer.
            // If we're here, no custom renderer was found.
            Text("Unknown Custom Component: \(instance.componentTypeName)")
                .foregroundColor(.red)
        }
    }
}
