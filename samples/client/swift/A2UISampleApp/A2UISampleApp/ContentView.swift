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
									Label(component.id, systemImage: component.type?.systemImage ?? "square")
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

							var systemImage: String {
							switch self {
							case .row: return "rectangle.split.3x1"
							case .column: return "rectangle.split.1x3"
							case .list: return "list.bullet"
							case .text: return "textformat"
							case .image: return "photo"
							case .icon: return "face.smiling"
							case .video: return "play.rectangle"
							case .audioPlayer: return "speaker.wave.2"
							case .button: return "hand.tap"
							case .textField: return "character.cursor.ibeam"
							case .checkbox: return "checkmark.square"
							case .slider: return "slider.horizontal.3"
							case .dateTimeInput: return "calendar"
							case .choicePicker: return "list.bullet.rectangle"
							case .tabs: return "menubar.rectangle"
							case .modal: return "square.stack"
							case .divider: return "minus"
							}
							}
							}
