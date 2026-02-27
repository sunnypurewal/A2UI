import SwiftUI
import A2UI

struct ComponentView: View {
	@Environment(A2UIDataStore.self) var dataStore
	@State private var jsonToShow: String?
	@State private var jsonTitle: String?
	@State private var component: GalleryComponent
	private let numberFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 4
		return formatter
	}()
	private let iso8601Formatter = ISO8601DateFormatter()
	
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
			
			if component.canEditProperties {
				VStack(alignment: .leading, spacing: 10) {
					ForEach($component.properties) { prop in
						HStack {
							Text(prop.wrappedValue.label)
								.font(.subheadline)
								.foregroundColor(.secondary)
							Spacer()
							propertyEditor(for: prop)
						}
					}
				}
				.padding()
				.background(Color(.secondarySystemBackground))
				.cornerRadius(10)
			}
			
			Button(action: {
				jsonTitle = "A2UI"
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

			if component.canEditDataModel {
				VStack(alignment: .leading, spacing: 10) {
					ForEach($component.dataModelFields) { field in
						if field.wrappedValue.showInEditor {
							HStack {
								Text(field.wrappedValue.label)
									.font(.subheadline)
									.foregroundColor(.secondary)
								Spacer()
								dataModelEditor(for: field)
							}
						}
					}
				}
				.padding()
				.background(Color(.secondarySystemBackground))
				.cornerRadius(10)
			}
			
			Button(action: {
				jsonTitle = "Data Model"
				jsonToShow = dataModelJson()
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
				.navigationTitle(jsonTitle ?? "JSON")
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

	@ViewBuilder
	private func propertyEditor(for prop: Binding<PropertyDefinition>) -> some View {
		if prop.wrappedValue.isDate {
			DatePicker("", selection: propertyDateBinding(for: prop))
				.labelsHidden()
				.onChange(of: prop.wrappedValue.value) {
					updateSurface(for: component)
				}
		} else if prop.wrappedValue.isBoolean {
			Toggle("", isOn: propertyBoolBinding(for: prop))
				.labelsHidden()
				.onChange(of: prop.wrappedValue.value) {
					updateSurface(for: component)
				}
		} else if !prop.wrappedValue.options.isEmpty {
			Picker(prop.wrappedValue.label, selection: propertyStringBinding(for: prop)) {
				ForEach(prop.wrappedValue.options, id: \.self) { option in
					Text(option).tag(option)
				}
			}
			.pickerStyle(.menu)
			.onChange(of: prop.wrappedValue.value) {
				updateSurface(for: component)
			}
		} else if let min = prop.wrappedValue.minValue, let max = prop.wrappedValue.maxValue {
			HStack {
				Slider(value: propertyNumericBinding(for: prop), in: min...max)
					.frame(width: 100)
				Text(prop.wrappedValue.value ?? "0")
					.font(.caption)
					.monospacedDigit()
					.frame(width: 40, alignment: .trailing)
			}
			.onChange(of: prop.wrappedValue.value) {
				updateSurface(for: component)
			}
		} else {
			TextField("", text: propertyStringBinding(for: prop))
				.textFieldStyle(.roundedBorder)
				.frame(width: 120)
				.onChange(of: prop.wrappedValue.value) {
					updateSurface(for: component)
				}
		}
	}

	private func propertyStringBinding(for prop: Binding<PropertyDefinition>) -> Binding<String> {
		Binding(
			get: { prop.wrappedValue.value ?? "" },
			set: { prop.wrappedValue.value = $0.isEmpty ? nil : $0 }
		)
	}

	private func propertyNumericBinding(for prop: Binding<PropertyDefinition>) -> Binding<Double> {
		Binding(
			get: {
				if let val = prop.wrappedValue.value {
					return Double(val) ?? 0
				}
				return 0
			},
			set: { newValue in
				prop.wrappedValue.value = String(format: "%.0f", newValue)
			}
		)
	}

	private func propertyBoolBinding(for prop: Binding<PropertyDefinition>) -> Binding<Bool> {
		Binding(
			get: {
				prop.wrappedValue.value == "true"
			},
			set: { newValue in
				prop.wrappedValue.value = newValue ? "true" : "false"
			}
		)
	}

	private func propertyDateBinding(for prop: Binding<PropertyDefinition>) -> Binding<Date> {
		Binding(
			get: {
				guard let value = prop.wrappedValue.value else {
					return Date()
				}
				return iso8601Formatter.date(from: value) ?? Date()
			},
			set: { newValue in
				prop.wrappedValue.value = iso8601Formatter.string(from: newValue)
			}
		)
	}

	private func updateDataModel(for field: DataModelField) {
		dataStore.process(chunk: field.updateDataModelA2UI(surfaceId: component.id))
		dataStore.flush()
	}

	private func dataModelJson() -> String {
		let dataModel = dataStore.surfaces[component.id]?.dataModel ?? buildDataModel()

		guard JSONSerialization.isValidJSONObject(dataModel),
			  let data = try? JSONSerialization.data(withJSONObject: dataModel, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]),
			  let pretty = String(data: data, encoding: .utf8) else {
			return "{}"
		}
		return pretty
	}

	private func buildDataModel() -> [String: Any] {
		var root: [String: Any] = [:]

		for field in component.dataModelFields {
			let segments = field.path.split(separator: "/").map(String.init)
			guard !segments.isEmpty else { continue }
			insert(value: field.value, into: &root, path: segments)
		}

		return root
	}

	private func insert(value: DataModelField.Value, into dict: inout [String: Any], path: [String]) {
		guard let head = path.first else { return }
		if path.count == 1 {
			dict[head] = jsonValue(for: value)
			return
		}

		var child = dict[head] as? [String: Any] ?? [:]
		insert(value: value, into: &child, path: Array(path.dropFirst()))
		dict[head] = child
	}

	private func jsonValue(for value: DataModelField.Value) -> Any {
		switch value {
		case .string(let stringValue):
			return stringValue
		case .number(let numberValue):
			return numberValue
		case .bool(let boolValue):
			return boolValue
		case .listObjects(let listValue):
			return listValue
		case .choice(let selected, _):
			return selected
		}
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
		case .listObjects:
			TextField("", text: listBinding(for: field))
				.textFieldStyle(.roundedBorder)
				.frame(width: 180)
		case .choice:
			Picker("", selection: choiceBinding(for: field)) {
				let options = getChoiceOptions(for: field.wrappedValue.value)
				ForEach(options, id: \.self) { option in
					Text(option).tag(option)
				}
			}
			.pickerStyle(.menu)
		}
	}

	private func getChoiceOptions(for value: DataModelField.Value) -> [String] {
		if case .choice(_, let options) = value {
			return options
		}
		return []
	}

	private func choiceBinding(for field: Binding<DataModelField>) -> Binding<String> {
		Binding(
			get: {
				if let surface = dataStore.surfaces[component.id],
				   let value = surface.getValue(at: field.wrappedValue.path) as? String {
					return value
				}
				if case .choice(let selected, _) = field.wrappedValue.value {
					return selected
				}
				return ""
			},
			set: { newValue in
				if case .choice(_, let options) = field.wrappedValue.value {
					field.wrappedValue.value = .choice(newValue, options)
					updateDataModel(for: field.wrappedValue)
				}
			}
		)
	}

	private func stringBinding(for field: Binding<DataModelField>) -> Binding<String> {
		Binding(
			get: {
				if let surface = dataStore.surfaces[component.id],
				   let value = surface.getValue(at: field.wrappedValue.path) as? String {
					return value
				}
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
				if let surface = dataStore.surfaces[component.id],
				   let value = surface.getValue(at: field.wrappedValue.path) as? Double {
					return value
				}
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
				if let surface = dataStore.surfaces[component.id],
				   let value = surface.getValue(at: field.wrappedValue.path) as? Bool {
					return value
				}
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

	private func listBinding(for field: Binding<DataModelField>) -> Binding<String> {
		Binding(
			get: {
				if let surface = dataStore.surfaces[component.id],
				   let value = surface.getValue(at: field.wrappedValue.path) as? [[String: Any]] {
					return jsonArrayLiteral(from: value)
				}
				if case .listObjects(let value) = field.wrappedValue.value {
					return jsonArrayLiteral(from: value)
				}
				return ""
			},
			set: { newValue in
				let parsed = jsonArrayObjects(from: newValue) ?? []
				field.wrappedValue.value = .listObjects(parsed)
				updateDataModel(for: field.wrappedValue)
			}
		)
	}

	private func jsonArrayObjects(from jsonArrayValue: String) -> [[String: Any]]? {
		guard let data = jsonArrayValue.data(using: .utf8),
			  let object = try? JSONSerialization.jsonObject(with: data),
			  let array = object as? [[String: Any]] else {
			return nil
		}
		return array
	}

	private func jsonArrayLiteral(from listValue: [[String: Any]]) -> String {
		guard JSONSerialization.isValidJSONObject(listValue),
			  let data = try? JSONSerialization.data(withJSONObject: listValue),
			  let jsonString = String(data: data, encoding: .utf8) else {
			return "[]"
		}
		return jsonString
	}
}

#Preview {
	NavigationView {
		ComponentView(component: GalleryComponent.row)
			.environment(A2UIDataStore())
	}
}
