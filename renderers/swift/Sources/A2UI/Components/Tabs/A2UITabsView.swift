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
