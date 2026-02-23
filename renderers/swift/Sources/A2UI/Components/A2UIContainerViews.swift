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
        if let list = properties.children.explicitList {
            ForEach(list, id: \.self) { id in
                A2UIComponentRenderer(componentId: id)
            }
        } else if let template = properties.children.template {
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

struct A2UITabsView: View {
    let properties: TabsProperties
    @Environment(SurfaceState.self) var surface
    @State private var selectedTab: Int = 0

    var body: some View {
        let tabs = properties.tabs
        VStack {
            Picker("", selection: $selectedTab) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Text(surface.resolve(tabs[index].title) ?? "Tab \(index)").tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if selectedTab < tabs.count {
                A2UIComponentRenderer(componentId: tabs[selectedTab].child)
            }
        }
    }
}

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
