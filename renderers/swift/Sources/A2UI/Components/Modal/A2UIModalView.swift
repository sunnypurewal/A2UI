import SwiftUI

struct A2UIModalView: View {
    let properties: ModalProperties
    @Environment(SurfaceState.self) var surface
    @State private var isPresented = false

    var body: some View {
        VStack {
            A2UIComponentRenderer(componentId: properties.trigger)
                .onTapGesture {
                    isPresented = true
                }
        }
        .sheet(isPresented: $isPresented) {
            VStack {
                HStack {
                    Spacer()
                    Button("Done") {
                        isPresented = false
                    }
                    .padding()
                }
                A2UIComponentRenderer(componentId: properties.content)
                Spacer()
            }
        }
    }
}

#Preview {
    let surface = SurfaceState(id: "test")
    let dataStore = A2UIDataStore()
    
    surface.components["trigger"] = ComponentInstance(id: "trigger", component: .button(ButtonProperties(child: "btn_text", action: .custom(name: "open", context: nil), variant: "primary")))
    surface.components["btn_text"] = ComponentInstance(id: "btn_text", component: .text(TextProperties(text: .init(literal: "Open Modal"), variant: nil)))
    surface.components["content"] = ComponentInstance(id: "content", component: .text(TextProperties(text: .init(literal: "This is the modal content"), variant: .h2)))
    
    return A2UIModalView(properties: ModalProperties(
        trigger: "trigger",
        content: "content"
    ))
    .padding()
    .environment(surface)
    .environment(dataStore)
}
