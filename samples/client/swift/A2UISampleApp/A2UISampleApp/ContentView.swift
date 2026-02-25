import SwiftUI
import A2UI

struct ContentView: View {
    @Environment(A2UIDataStore.self) var dataStore
    @State private var jsonToShow: String?
	@State private var selectedComponent: String?

    var body: some View {
        NavigationView {
			List(ComponentCategory.allCases, id: \.self) { category in
				NavigationLink(destination: category.linkDestination) {
					Text(category.rawValue)
				}
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

enum ComponentCategory: String, CaseIterable {
	case layout = "Layout"
	case content = "Content"
	case input = "Input"
	case navigation = "Navigation"
	case decoration = "Decoration"
	var linkDestination: some View {
		switch self {
			case .layout:
				return AnyView(LayoutOptionsView())
			default:
				return AnyView(Text("\(rawValue) Detail"))
		}
	}
}


