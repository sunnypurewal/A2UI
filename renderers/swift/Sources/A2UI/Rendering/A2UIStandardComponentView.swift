import SwiftUI

/// A view that maps a standard A2UI component instance to its SwiftUI implementation.
struct A2UIStandardComponentView: View {
    let instance: ComponentInstance

    var body: some View {
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
            // Custom components should have been handled by the customRenderer check in A2UIComponentRenderer.
            // If we're here, no custom renderer was found.
            Text("Unknown Custom Component: \(instance.componentTypeName)")
                .foregroundColor(.red)
        }
    }
}
