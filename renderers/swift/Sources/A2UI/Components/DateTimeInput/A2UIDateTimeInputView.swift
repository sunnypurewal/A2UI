import SwiftUI

struct A2UIDateTimeInputView: View {
    let id: String
    let properties: DateTimeInputProperties
    @Environment(SurfaceState.self) var surfaceEnv: SurfaceState?
    var surface: SurfaceState?
    
    private var activeSurface: SurfaceState? { surface ?? surfaceEnv }

    init(id: String, properties: DateTimeInputProperties, surface: SurfaceState? = nil) {
        self.id = id
        self.properties = properties
        self.surface = surface
    }

    var body: some View {
        let dateBinding = Binding<Date>(
            get: {
                resolvedValue() ?? Date()
            },
            set: { newValue in
                updateDate(newValue)
                activeSurface?.runChecks(for: id)
            }
        )

        VStack(alignment: .leading, spacing: 0) {
            DatePicker(
                resolveValue(activeSurface, binding: properties.label) ?? "",
                selection: dateBinding,
                in: dateRange,
                displayedComponents: dateComponents
            )
            ValidationErrorMessageView(id: id, surface: activeSurface)
        }
        .onAppear {
            activeSurface?.runChecks(for: id)
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
        let minDate = resolvedDate(from: resolveValue(activeSurface, binding: properties.min)) ?? Date.distantPast
        let maxDate = resolvedDate(from: resolveValue(activeSurface, binding: properties.max)) ?? Date.distantFuture
        return minDate...maxDate
    }

    private func resolvedValue() -> Date? {
        let formatter = ISO8601DateFormatter()
        if let value = activeSurface?.resolve(properties.value) {
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
        activeSurface?.triggerDataUpdate(path: path, value: dateString)
    }
}

#Preview {
    let surface = SurfaceState(id: "test")
    let dataStore = A2UIDataStore()
    
    VStack(spacing: 20) {
        A2UIDateTimeInputView(id: "dt1", properties: DateTimeInputProperties(
            label: .init(literal: "Date and Time"),
            value: .init(literal: "2024-01-01T12:00:00Z"),
            enableDate: true,
            enableTime: true,
            min: nil,
            max: nil
        ))
        
        A2UIDateTimeInputView(id: "dt2", properties: DateTimeInputProperties(
            label: .init(literal: "Date Only"),
            value: .init(literal: "2024-01-01T12:00:00Z"),
            enableDate: true,
            enableTime: false,
            min: nil,
            max: nil
        ))
    }
    .padding()
    .environment(surface)
    .environment(dataStore)
}
