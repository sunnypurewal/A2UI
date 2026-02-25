import SwiftUI

struct A2UIRowView: View {
    let properties: ContainerProperties
    @Environment(SurfaceState.self) var surface

    var body: some View {
        HStack(alignment: verticalAlignment) {
            renderChildren()
        }
        .frame(maxWidth: .infinity, alignment: horizontalAlignment)
    }

    @ViewBuilder
    private func renderChildren() -> some View {
        switch properties.children {
        case .list(let list):
            ForEach(list, id: \.self) { id in
                A2UIComponentRenderer(componentId: id)
            }
        case .template(let template):
            let ids = surface.expandTemplate(template: template)
            ForEach(ids, id: \.self) { id in
                A2UIComponentRenderer(componentId: id)
            }
        }
    }

    private var verticalAlignment: VerticalAlignment {
        switch properties.align {
			case .start: return .top
			case .center: return .center
			case .end: return .bottom
			default: return .center
        }
    }

    private var horizontalAlignment: Alignment {
        switch properties.justify {
			case .start: return .leading
			case .center: return .center
			case .end: return .trailing
			default: return .leading
        }
    }
}

struct A2UIColumnView: View {
    let properties: ContainerProperties
    @Environment(SurfaceState.self) var surface

    var body: some View {
        VStack(alignment: horizontalAlignment, spacing: 8) {
            renderChildren()
        }
        .frame(maxWidth: .infinity, alignment: horizontalAlignment == .leading ? .leading : (horizontalAlignment == .trailing ? .trailing : .center))
    }

    @ViewBuilder
    private func renderChildren() -> some View {
        switch properties.children {
        case .list(let list):
            ForEach(list, id: \.self) { id in
                A2UIComponentRenderer(componentId: id)
            }
        case .template(let template):
            let ids = surface.expandTemplate(template: template)
            ForEach(ids, id: \.self) { id in
                A2UIComponentRenderer(componentId: id)
            }
        }
    }

    private var horizontalAlignment: HorizontalAlignment {
		switch properties.align {
			case .start: return .leading
			case .center: return .center
			case .end: return .trailing
			default: return .leading
        }
    }
}
