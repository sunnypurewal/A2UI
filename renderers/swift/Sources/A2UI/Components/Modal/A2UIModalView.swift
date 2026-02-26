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
