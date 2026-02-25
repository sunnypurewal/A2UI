import SwiftUI
import A2UI

struct ContentView: View {
    @Environment(A2UIDataStore.self) var dataStore
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


