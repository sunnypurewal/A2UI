import SwiftUI

struct A2UICardView: View {
    let properties: CardProperties

    var body: some View {
        A2UIComponentRenderer(componentId: properties.child)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(white: 0.95))
            )
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    let surface = SurfaceState(id: "test")
    let dataStore = A2UIDataStore()
    
    surface.components["t1"] = ComponentInstance(id: "t1", component: .text(TextProperties(text: .init(literal: "Card Content"), variant: .h3)))
    
    return A2UICardView(properties: CardProperties(child: "t1"))
        .padding()
        .environment(surface)
        .environment(dataStore)
}
