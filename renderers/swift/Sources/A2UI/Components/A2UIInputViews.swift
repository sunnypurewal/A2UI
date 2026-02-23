import SwiftUI

struct A2UITextFieldView: View {
    let properties: TextFieldProperties
    @Environment(SurfaceState.self) var surface
    @State private var text: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(resolveValue(surface, binding: properties.label) ?? "")
                .font(.caption)
                .foregroundColor(.secondary)

            TextField("", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: text) { newValue in
                    updateBinding(surface: surface, binding: properties.value, newValue: newValue)
                }
        }
        .onAppear {
            text = resolveValue(surface, binding: properties.value) ?? ""
        }
    }
}

struct A2UICheckBoxView: View {
    let properties: CheckBoxProperties
    @Environment(SurfaceState.self) var surface
    @State private var isOn: Bool = false

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(resolveValue(surface, binding: properties.label) ?? "")
        }
        .toggleStyle(CheckBoxToggleStyle())
        .onChange(of: isOn) { newValue in
            updateBinding(surface: surface, binding: properties.value, newValue: newValue)
        }
        .onAppear {
            isOn = resolveValue(surface, binding: properties.value) ?? false
        }
    }
}

struct A2UISliderView: View {
    let properties: SliderProperties
    @Environment(SurfaceState.self) var surface
    @State private var value: Double = 0

    var body: some View {
        VStack(alignment: .leading) {
            if let label = properties.label, let labelText = surface.resolve(label) {
                Text(labelText)
                    .font(.caption)
            }

            Slider(value: $value, in: properties.min...properties.max) {
                Text("Slider")
            } minimumValueLabel: {
                Text("\(Int(properties.min))")
            } maximumValueLabel: {
                Text("\(Int(properties.max))")
            }
            .onChange(of: value) { newValue in
                updateBinding(surface: surface, binding: properties.value, newValue: newValue)
            }
        }
        .onAppear {
            value = resolveValue(surface, binding: properties.value) ?? properties.min
        }
    }
}

struct A2UIChoicePickerView: View {
    let properties: ChoicePickerProperties
    @Environment(SurfaceState.self) var surface
    @State private var selections: Set<String> = []

    var body: some View {
        VStack(alignment: .leading) {
            if let label = properties.label, let labelText = surface.resolve(label) {
                Text(labelText)
                    .font(.caption)
            }

            if properties.variant == "mutuallyExclusive" {
                Picker("", selection: Binding(
                    get: { selections.first ?? "" },
                    set: { newValue in
                        selections = newValue.isEmpty ? [] : [newValue]
                    }
                )) {
                    ForEach(properties.options, id: \.value) { option in
                        Text(surface.resolve(option.label) ?? option.value).tag(option.value)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            } else {
                ForEach(properties.options, id: \.value) { option in
                    Toggle(isOn: Binding(
                        get: { selections.contains(option.value) },
                        set: { isOn in
                            if isOn {
                                selections.insert(option.value)
                            } else {
                                selections.remove(option.value)
                            }
                        }
                    )) {
                        Text(surface.resolve(option.label) ?? option.value)
                    }
                }
            }
        }
        .onChange(of: selections) { newValue in
            updateBinding(surface: surface, binding: properties.value, newValue: Array(newValue))
        }
        .onAppear {
            if let initial = surface.resolve(properties.value) {
                selections = Set(initial)
            }
        }
    }
}

struct A2UIDateTimeInputView: View {
    let properties: DateTimeInputProperties
    @Environment(SurfaceState.self) var surface
    @State private var date: Date = Date()

    var body: some View {
        DatePicker(
            resolveValue(surface, binding: properties.label) ?? "",
            selection: $date,
            in: dateRange,
            displayedComponents: dateComponents
        )
        .onChange(of: date) { newValue in
            updateDate(newValue)
        }
        .onAppear {
            if let resolved = resolvedValue() {
                date = resolved
            }
        }
    }

    private var dateComponents: DatePickerComponents {
        var components: DatePickerComponents = []
        if properties.enableDate ?? true {
            components.insert(.date)
        }
        if properties.enableTime ?? true {
            components.insert(.hourAndMinute)
        }
        return components.isEmpty ? [.date, .hourAndMinute] : components
    }

    private var dateRange: ClosedRange<Date> {
        let formatter = ISO8601DateFormatter()
        let minDate = resolvedDate(from: resolveValue(surface, binding: properties.min)) ?? Date.distantPast
        let maxDate = resolvedDate(from: resolveValue(surface, binding: properties.max)) ?? Date.distantFuture
        return minDate...maxDate
    }

    private func resolvedValue() -> Date? {
        let formatter = ISO8601DateFormatter()
        if let value = surface.resolve(properties.value) {
            return formatter.date(from: value)
        }
        return nil
    }

    private func resolvedDate(from string: String?) -> Date? {
        guard let str = string else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: str)
    }

    private func updateDate(_ newValue: Date) {
        guard let path = properties.value.path else { return }
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: newValue)
        surface.trigger(action: .dataUpdate(DataUpdateAction(path: path, contents: AnyCodable(dateString))))
    }
}

@MainActor fileprivate func updateBinding<T: Sendable>(surface: SurfaceState, binding: BoundValue<T>?, newValue: T) {
    guard let path = binding?.path else { return }
    surface.trigger(action: .dataUpdate(DataUpdateAction(path: path, contents: AnyCodable(newValue))))
}

@MainActor fileprivate func resolveValue<T>(_ surface: SurfaceState, binding: BoundValue<T>?) -> T? {
    guard let binding = binding else { return nil }
    return surface.resolve(binding)
}

struct CheckBoxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
        }
    }
}
