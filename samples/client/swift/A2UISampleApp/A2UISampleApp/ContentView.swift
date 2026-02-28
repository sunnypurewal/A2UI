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
							Label(category.rawValue, systemImage: category.systemImage)
						}
					}
				}

				Section(header: Text("App")) {
					NavigationLink {
						ResourcesView()
					} label: {
						Label("Resources", systemImage: "books.vertical.fill")
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
	
	var systemImage: String {
		switch self {
		case .layout: return "rectangle.3.group"
		case .content: return "doc.text"
		case .input: return "keyboard"
		case .navigation: return "location.fill"
		case .decoration: return "sparkles"
		case .functions: return "function"
		}
	}
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
	case button = "Button"
	case textField = "TextField"
	case checkbox = "CheckBox"
	case slider = "Slider"
	case dateTimeInput = "DateTimeInput"
	case choicePicker = "ChoicePicker"
	case tabs = "Tabs"
	case modal = "Modal"
	case divider = "Divider"
}
