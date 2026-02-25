import SwiftUI
import A2UI

struct ContentView: View {
    @Environment(A2UIDataStore.self) var dataStore
	@State private var selectedComponent: String?

    var body: some View {
        NavigationView {
			List(ComponentCategory.allCases, id: \.self) { category in
				NavigationLink {
					let components = GalleryData.components(for: category)
					List {
						ForEach(components) { component in
							NavigationLink {
								ComponentView(component: component)
							} label: {
								Text(component.id.rawValue)
							}

						}
					}
//					List(components, id: \.self) { component in
//						NavigationLink(destination: ComponentView(component: component)) {
//							Text(component.id.rawValue)
//						}
//					}
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
