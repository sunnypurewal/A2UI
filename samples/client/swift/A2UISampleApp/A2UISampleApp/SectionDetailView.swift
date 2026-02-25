import SwiftUI
import A2UI

struct SectionDetailView: View {
	let section: GalleryData.Section
	@Binding var jsonToShow: String?
	
	var body: some View {
		VStack {
			ForEach(section.subsections) { subsection in
				VStack(spacing: 15) {
					A2UISurfaceView(surfaceId: subsection.id)
					Button(action: {
						jsonToShow = subsection.prettyJson
					}) {
						Label("Show JSON", systemImage: "doc.text")
					}
					.padding()
					.background(Color(.secondarySystemBackground))
					.cornerRadius(10)
				}
			}
		}
	}
}
