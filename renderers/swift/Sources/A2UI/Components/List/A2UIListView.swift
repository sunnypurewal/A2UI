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
