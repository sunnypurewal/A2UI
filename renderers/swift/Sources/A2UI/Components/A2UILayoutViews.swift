import SwiftUI

struct A2UIRowView: View {
    let properties: ContainerProperties
    @Environment(SurfaceState.self) var surface

    var body: some View {
        let childIds: [String] = {
            switch properties.children {
            case .list(let list): return list
            case .template(let template): return surface.expandTemplate(template: template)
            }
        }()

        HStack(alignment: verticalAlignment, spacing: 0) {
            if properties.resolvedJustify == .end || properties.resolvedJustify == .center || properties.resolvedJustify == .spaceEvenly || properties.resolvedJustify == .spaceAround {
                Spacer(minLength: 0)
            }

            ForEach(Array(childIds.enumerated()), id: \.offset) { index, id in
                A2UIComponentRenderer(componentId: id)
                if index < childIds.count - 1 {
                    if properties.resolvedJustify == .spaceBetween || properties.resolvedJustify == .spaceEvenly || properties.resolvedJustify == .spaceAround {
                        Spacer(minLength: 0)
                    }
                }
            }

            if properties.resolvedJustify == .start || properties.resolvedJustify == .center || properties.resolvedJustify == .spaceEvenly || properties.resolvedJustify == .spaceAround {
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var verticalAlignment: VerticalAlignment {
        switch properties.resolvedAlign {
        case .start: return .top
        case .center: return .center
        case .end: return .bottom
        default: return .center
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
