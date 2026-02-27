import SwiftUI
import A2UI

struct ContentView: View {
    @Environment(A2UIDataStore.self) var dataStore
	@State private var selectedComponent: String?

    var body: some View {
        NavigationView {
			List {
				Section(header: Text("Gallery")) {
					ForEach(ComponentCategory.allCases, id: \.self) { category in
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
				}

				Section(header: Text("App")) {
					NavigationLink {
						ResourcesView()
					} label: {
						Label("Resources & Settings", systemImage: "gearshape")
					}
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
	case functions = "Functions"
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
	case textField = "TextField"
	case checkbox = "CheckBox"
	case slider = "Slider"
	case dateTimeInput = "DateTimeInput"
	case choicePicker = "ChoicePicker"
	case button = "Button"
	case tabs = "Tabs"
	case modal = "Modal"
	case divider = "Divider"
}
