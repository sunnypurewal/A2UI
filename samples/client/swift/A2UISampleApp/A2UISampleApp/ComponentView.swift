import SwiftUI
import A2UI

struct ComponentView: View {
	@Environment(A2UIDataStore.self) var dataStore
	@State private var jsonToShow: String?
	@State private var component: GalleryComponent
	
	init(component: GalleryComponent) {
		self._component = State(initialValue: component)
	}
	
	var body: some View {
		VStack {
			A2UISurfaceView(surfaceId: component.id)
				.padding()
				.background(Color(.systemBackground))
				.cornerRadius(12)
				.shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
			
			if !component.properties.isEmpty {
				VStack(alignment: .leading, spacing: 10) {
					ForEach($component.properties) { prop in
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
								updateSurface(for: component)
							}
						}
					}
				}
				.padding()
				.background(Color(.secondarySystemBackground))
				.cornerRadius(10)
			}
			
			
			Button(action: {
				jsonToShow = component.prettyJson
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
		.onAppear {
			dataStore.process(chunk: component.a2ui)
			dataStore.flush()
		}
		.sheet(isPresented: Binding(
			get: { jsonToShow != nil },
			set: { if !$0 { jsonToShow = nil } }
		)) {
			NavigationView {
				ScrollView {
					Text(jsonToShow ?? "")
						.font(.system(.body, design: .monospaced))
						.padding()
						.frame(maxWidth: .infinity, alignment: .leading)
				}
				.navigationTitle("A2UI JSON")
				.toolbar {
					ToolbarItem(placement: .navigationBarTrailing) {
						Button("Done") {
							jsonToShow = nil
						}
					}
				}
			}
		}
		.navigationTitle(component.id)
	}
	
	private func updateSurface(for component: GalleryComponent) {
		dataStore.process(chunk: component.updateComponentsA2UI)
		dataStore.flush()
	}
}

#Preview {
	NavigationView {
		ComponentView(component: GalleryComponent.row)
	}
}
