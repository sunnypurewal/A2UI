import SwiftUI
import A2UI

struct ContentView: View {
    @Environment(A2UIDataStore.self) var dataStore
    @State private var jsonToShow: String?

    let categories = ["Layout", "Content", "Input", "Navigation", "Decoration"]

    var body: some View {
        NavigationView {
			List(categories, id: \.self) { category in
                Text(category)
            }
            .navigationTitle("A2UI Gallery")
        }
        .sheet(isPresented: Binding(
            get: { jsonToShow != nil },
            set: { if !$0 { jsonToShow = nil } }
        )) {
            NavigationView {
                ScrollView {
                    Text(jsonToShow ?? "")
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .navigationTitle("A2UI JSON")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            jsonToShow = nil
                        }
                    }
                }
            }
        }
    }
}
