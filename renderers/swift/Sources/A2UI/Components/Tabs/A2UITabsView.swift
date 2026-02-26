import SwiftUI

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

#Preview {
    let surface = SurfaceState(id: "test")
    let dataStore = A2UIDataStore()
    
    surface.components["t1"] = ComponentInstance(id: "t1", component: .text(TextProperties(text: .init(literal: "Content for Tab 1"), variant: nil)))
    surface.components["t2"] = ComponentInstance(id: "t2", component: .text(TextProperties(text: .init(literal: "Content for Tab 2"), variant: nil)))
    
    return A2UITabsView(properties: TabsProperties(
        tabs: [
            TabItem(title: .init(literal: "Tab 1"), child: "t1"),
            TabItem(title: .init(literal: "Tab 2"), child: "t2")
        ]
    ))
    .padding()
    .environment(surface)
    .environment(dataStore)
}
