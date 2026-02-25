import SwiftUI
import A2UI

struct ComponentView: View {
	@Environment(A2UIDataStore.self) var dataStore
	@State private var jsonToShow: String?
	@State private var component: GalleryComponent
	private let numberFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 4
		return formatter
	}()
	
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
				.frame(height: 200)
			
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
				Label("A2UI JSON", systemImage: "doc.text")
					.font(.footnote)
			}
			.buttonStyle(PlainButtonStyle())
			.padding(.horizontal, 12)
			.padding(.vertical, 8)
			.background(Color.accentColor.opacity(0.1))
			.cornerRadius(8)

			if !component.dataModelFields.isEmpty {
				VStack(alignment: .leading, spacing: 10) {
					ForEach($component.dataModelFields) { field in
						HStack {
							Text(field.wrappedValue.label)
								.font(.subheadline)
								.foregroundColor(.secondary)
							Spacer()
							dataModelEditor(for: field)
						}
					}
				}
				.padding()
				.background(Color(.secondarySystemBackground))
				.cornerRadius(10)
			}
			
			Button(action: {
				/// TODO: Show Data Model JSON
			}) {
				Label("Data Model JSON", systemImage: "doc.text")
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

	private func updateDataModel(for field: DataModelField) {
		dataStore.process(chunk: field.updateDataModelA2UI(surfaceId: component.id))
		dataStore.flush()
	}

	@ViewBuilder
	private func dataModelEditor(for field: Binding<DataModelField>) -> some View {
		switch field.wrappedValue.value {
		case .string:
			TextField("", text: stringBinding(for: field))
				.textFieldStyle(.roundedBorder)
				.frame(width: 180)
		case .number:
			TextField("", value: numberBinding(for: field), formatter: numberFormatter)
				.textFieldStyle(.roundedBorder)
				.frame(width: 120)
		case .bool:
			Toggle("", isOn: boolBinding(for: field))
				.labelsHidden()
		}
	}

	private func stringBinding(for field: Binding<DataModelField>) -> Binding<String> {
		Binding(
			get: {
				if case .string(let value) = field.wrappedValue.value {
					return value
				}
				return ""
			},
			set: { newValue in
				field.wrappedValue.value = .string(newValue)
				updateDataModel(for: field.wrappedValue)
			}
		)
	}

	private func numberBinding(for field: Binding<DataModelField>) -> Binding<Double> {
		Binding(
			get: {
				if case .number(let value) = field.wrappedValue.value {
					return value
				}
				return 0
			},
			set: { newValue in
				field.wrappedValue.value = .number(newValue)
				updateDataModel(for: field.wrappedValue)
			}
		)
	}

	private func boolBinding(for field: Binding<DataModelField>) -> Binding<Bool> {
		Binding(
			get: {
				if case .bool(let value) = field.wrappedValue.value {
					return value
				}
				return false
			},
			set: { newValue in
				field.wrappedValue.value = .bool(newValue)
				updateDataModel(for: field.wrappedValue)
			}
		)
	}
}

#Preview {
	NavigationView {
		ComponentView(component: GalleryComponent.row)
	}
}
