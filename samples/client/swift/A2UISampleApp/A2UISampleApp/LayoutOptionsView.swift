import SwiftUI
import A2UI

struct LayoutOptionsView: View {
    var body: some View {
		List(LayoutComponents.allCases, id: \.self) { component in
			if let component = GalleryData.all[.layout]?[component.rawValue] {
				ComponentView(component: component)
			}
        }
        .navigationTitle("Layout")
    }
}

enum LayoutComponents: String, CaseIterable {
	case row = "Row"
	case column = "Column"
	case list = "List"
	case card = "Card"
}

#Preview {
    NavigationView {
        LayoutOptionsView()
    }
}
