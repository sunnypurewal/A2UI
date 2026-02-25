import SwiftUI
import A2UI

struct SectionDetailView: View {
	@Environment(A2UIDataStore.self) var dataStore
	let section: GalleryData.Section
	@Binding var jsonToShow: String?
	
	@State private var subsections: [GalleryData.SubSection]
	
	init(section: GalleryData.Section, jsonToShow: Binding<String?>) {
		self.section = section
		self._jsonToShow = jsonToShow
		self._subsections = State(initialValue: section.subsections)
	}
	
	var body: some View {
		Section(section.name) {
			ForEach($subsections) { subsection in
				VStack(alignment: .leading, spacing: 15) {
					Text(subsection.wrappedValue.id)
						.font(.headline)
					
					A2UISurfaceView(surfaceId: subsection.wrappedValue.id)
						.padding()
						.background(Color(.systemBackground))
						.cornerRadius(12)
						.shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)

					if !subsection.wrappedValue.properties.isEmpty {
						VStack(alignment: .leading, spacing: 10) {
							ForEach(subsection.properties) { prop in
								HStack {
									Text(prop.wrappedValue.label)
										.font(.subheadline)
										.foregroundColor(.secondary)
									Spacer()
									Picker(prop.wrappedValue.label, selection: prop.value) {
										ForEach(prop.wrappedValue.options, id: \.self) { option in
											Text(option).tag(option)
										}
									}
									.pickerStyle(.menu)
									.onChange(of: prop.wrappedValue.value) {
										updateSurface(for: subsection.wrappedValue)
									}
								}
							}
						}
						.padding()
						.background(Color(.secondarySystemBackground))
						.cornerRadius(10)
					}

					Button(action: {
						jsonToShow = subsection.wrappedValue.prettyJson
					}) {
						Label("Show JSON", systemImage: "doc.text")
							.font(.footnote)
					}
					.buttonStyle(PlainButtonStyle())
					.padding(.horizontal, 12)
					.padding(.vertical, 8)
					.background(Color.accentColor.opacity(0.1))
					.cornerRadius(8)
				}
				.padding(.vertical, 10)
			}
		}
	}
	
	private func updateSurface(for subsection: GalleryData.SubSection) {
		dataStore.process(chunk: subsection.updateComponentsA2UI)
		dataStore.flush()
	}
}
