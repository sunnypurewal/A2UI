import SwiftUI

struct ResourcesView: View {
    var body: some View {
        List {
            Section(header: Text("Information")) {
                Text("A2UI Documentation")
                Text("Version 1.0.0")
            }
            
            Section(header: Text("Settings")) {
                Toggle("Enable Notifications", isOn: .constant(true))
                Text("Appearance")
            }
        }
        .navigationTitle("Resources & Settings")
    }
}

#Preview {
    NavigationView {
        ResourcesView()
    }
}
