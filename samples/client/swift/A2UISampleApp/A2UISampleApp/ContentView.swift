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
							List {
								let components = GalleryData.components(for: category)
								ForEach(components, id: \.self) { component in
									NavigationLink {
										ComponentView(component: component)
									} label: {
										Label(component.id, systemImage: component.systemImage)
									}
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
			case .navigation: return "filemenu.and.selection"
			case .decoration: return "sparkles"
			case .functions: return "function"
		}
	}
}

extension GalleryComponent {
	var systemImage: String {
		switch id {
			case "Row": return "rectangle.split.1x2"
			case "Column": return "rectangle.split.2x1"
			case "List": return "list.bullet"
			case "Text": return "textformat"
			case "Image": return "photo"
			case "Icon": return "face.smiling"
			case "Video": return "play.rectangle"
			case "AudioPlayer": return "speaker.wave.2"
			case "Button": return "hand.tap"
			case "TextField": return "character.cursor.ibeam"
			case "CheckBox": return "checkmark.square"
			case "Slider": return "slider.horizontal.3"
			case "DateTimeInput": return "calendar"
			case "ChoicePicker": return "list.bullet.rectangle"
			case "Tabs": return "menubar.rectangle"
			case "Modal": return "square.stack"
			case "Divider": return "minus"
			case "email": return "envelope"
			case "required": return "questionmark.circle"
			case "length": return "number"
			case "regex": return "text.magnifyingglass"
			case "numeric": return "123.rectangle"
			case "formatDate": return "calendar"
			case "formatCurrency": return "dollarsign.circle"
			case "pluralize": return "list.bullet"
			default: return "questionmark.circle"
		}
	}
}
