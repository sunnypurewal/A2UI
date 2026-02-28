import SwiftUI

struct ResourcesView: View {
	@Environment(\.openURL) var openURL
    var body: some View {
        List {
			Text("A2UI on GitHub")
				.onTapGesture {
					openURL(URL(string:"https://github.com/google/a2ui")!)
				}
			Text("Sample App README")
				.onTapGesture {
					openURL(URL(string:"https://github.com/sunnypurewal/A2UI/blob/main/samples/client/swift/README.md")!)
				}
			Text("SwiftUI Renderer README")
				.onTapGesture {
					openURL(URL(string:"https://github.com/sunnypurewal/A2UI/blob/main/renderers/swift/README.md")!)
				}
        }
		.listStyle(.plain)
		.padding()
        .navigationTitle("Resources")
    }
}

#Preview {
    NavigationView {
        ResourcesView()
    }
}
