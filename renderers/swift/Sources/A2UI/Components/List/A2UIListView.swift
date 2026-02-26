import SwiftUI

struct A2UIListView: View {
    let properties: ListProperties
    @Environment(SurfaceState.self) var surface
    private var axis: Axis.Set {
        properties.direction == "horizontal" ? .horizontal : .vertical
    }
    
    var body: some View {
        ScrollView(axis, showsIndicators: true) {
            if axis == .horizontal {
                HStack(spacing: 0) {
                    renderChildren()
                }
            } else {
                VStack(spacing: 0) {
                    renderChildren()
                }
            }
        }
    }

    @ViewBuilder
    private func renderChildren() -> some View {
        switch properties.children {
        case .list(let list):
            ForEach(list, id: \.self) { id in
                A2UIComponentRenderer(componentId: id)
            }
        case .template(let template):
            renderTemplate(template)
        }
    }

    @ViewBuilder
    private func renderTemplate(_ template: Template) -> some View {
        let ids = surface.expandTemplate(template: template)
        ForEach(ids, id: \.self) { id in
            A2UIComponentRenderer(componentId: id)
        }
    }
}

#Preview {
    let surface = SurfaceState(id: "test")
    let dataStore = A2UIDataStore()
    
    surface.components["t1"] = ComponentInstance(id: "t1", component: .text(TextProperties(text: .init(literal: "Item 1"), variant: nil)))
    surface.components["t2"] = ComponentInstance(id: "t2", component: .text(TextProperties(text: .init(literal: "Item 2"), variant: nil)))
    surface.components["t3"] = ComponentInstance(id: "t3", component: .text(TextProperties(text: .init(literal: "Item 3"), variant: nil)))
    
    return A2UIListView(properties: ListProperties(
        children: .list(["t1", "t2", "t3"]),
        direction: "vertical",
        align: "start"
    ))
    .padding()
    .environment(surface)
    .environment(dataStore)
}
