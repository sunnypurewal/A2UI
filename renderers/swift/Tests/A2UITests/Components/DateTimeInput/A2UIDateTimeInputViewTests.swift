import XCTest
import SwiftUI
import ViewInspector
@testable import A2UI

final class A2UIDateTimeInputViewTests: XCTestCase {
    
    @MainActor
    func testDateTimeInputViewBasic() throws {
        let surface = SurfaceState(id: "test")
        let props = DateTimeInputProperties(
            label: BoundValue(literal: "Test Label"),
            value: BoundValue(path: "/date"),
            enableDate: true,
            enableTime: true,
            min: BoundValue(literal: "2024-01-01T00:00:00Z"),
            max: BoundValue(literal: "2024-12-31T23:59:59Z")
        )
        
        surface.setValue(at: "/date", value: "2024-06-01T12:00:00Z")
        
        var capturedAction: UserAction?
        surface.actionHandler = { action in
            capturedAction = action
            if case .dataUpdate(let dataUpdate) = action.action {
                surface.setValue(at: dataUpdate.path, value: dataUpdate.contents.value)
            }
        }
        
        let view = A2UIDateTimeInputView(id: "dt1", properties: props, surface: surface)
        let datePicker = try view.inspect().find(ViewType.DatePicker.self)
        
        let label = try datePicker.labelView().text().string()
        XCTAssertEqual(label, "Test Label")
        
        // Test setting a new date
        let formatter = ISO8601DateFormatter()
        let newDate = formatter.date(from: "2024-07-01T12:00:00Z")!
        try datePicker.select(date: newDate)
        
        XCTAssertEqual(surface.getValue(at: "/date") as? String, "2024-07-01T12:00:00Z")
    }

    @MainActor
    func testDateTimeInputViewEdgeCases() throws {
        let surface = SurfaceState(id: "test")
        
        // Empty min/max
        let props = DateTimeInputProperties(
            label: nil,
            value: BoundValue(literal: "invalid-date"),
            enableDate: false,
            enableTime: false,
            min: nil,
            max: nil
        )
        
        let view = A2UIDateTimeInputView(id: "dt2", properties: props, surface: surface)
        let datePicker = try view.inspect().find(ViewType.DatePicker.self)
        
        // Literal date fallback to current date or invalid date handles
        let label = try datePicker.labelView().text().string()
        XCTAssertEqual(label, "")
    }
}

