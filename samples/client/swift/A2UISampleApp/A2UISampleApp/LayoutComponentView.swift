import SwiftUI

struct LayoutComponentView: View {
	let options = ["Row", "Column", "List", "Card"]
	
	var body: some View {
		List(options, id: \.self) { option in
			NavigationLink(destination: Text("\(option) Detail")) {
				Text(option)
			}
		}
		.navigationTitle("Layout")
	}
}

#Preview {
	NavigationView {
		LayoutComponentView()
	}
}
