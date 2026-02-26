import SwiftUI

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
        .onChange(of: date) { _, newValue in
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

#Preview {
    let surface = SurfaceState(id: "test")
    let dataStore = A2UIDataStore()
    
    VStack(spacing: 20) {
        A2UIDateTimeInputView(properties: DateTimeInputProperties(
            label: .init(literal: "Date and Time"),
            value: .init(literal: "2024-01-01T12:00:00Z"),
            enableDate: true,
            enableTime: true,
            min: nil,
            max: nil
        ))
        
        A2UIDateTimeInputView(properties: DateTimeInputProperties(
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
