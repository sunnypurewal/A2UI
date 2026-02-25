import SwiftUI
import A2UI

struct ContentView: View {
    @Environment(A2UIDataStore.self) var dataStore
	@State private var selectedComponent: String?

    var body: some View {
        NavigationView {
			List(ComponentCategory.allCases, id: \.self) { category in
				NavigationLink {
					List(GalleryData.components(for: category)) { component in
						NavigationLink {
							ComponentView(component: component)
						} label: {
							Text(component.id)
						}
					}
					.navigationTitle(category.rawValue)
				} label: {
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
}

enum ComponentType: String {
	case row = "Row"
	case column = "Column"
	case list = "List"
	case text = "Text"
	case image = "Image"
	case icon = "Icon"
	case video = "Video"
	case audioPlayer = "AudioPlayer"
}
