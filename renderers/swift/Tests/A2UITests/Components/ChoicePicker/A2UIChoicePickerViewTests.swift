import XCTest
import SwiftUI
import ViewInspector
@testable import A2UI

final class A2UIChoicePickerViewTests: XCTestCase {
    @MainActor
    func testMutuallyExclusivePicker() throws {
        let surface = SurfaceState(id: "test")
        let options = [
            SelectionOption(label: .init(literal: "Opt 1"), value: "o1"),
            SelectionOption(label: .init(literal: "Opt 2"), value: "o2")
        ]
        let props = ChoicePickerProperties(
            label: .init(literal: "Pick one"),
            options: options,
            variant: .mutuallyExclusive,
            value: .init(path: "selection")
        )
        surface.dataModel["selection"] = ["o1"]
        
        let view = A2UIChoicePickerView(id: "cp1", properties: props, surface: surface)
        
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let picker = try view.inspect().find(ViewType.Picker.self)
        XCTAssertNotNil(picker)
        
        // Test options rendering
        // Depending on SwiftUI version, Picker might have an internal label view.
        // We just care that it renders.
        XCTAssertTrue(try picker.findAll(ViewType.Text.self).count >= 2)
        
        // Test binding set
        try picker.select(value: "o2")
    }

    @MainActor
    func testMultipleSelectionPicker() throws {
        let surface = SurfaceState(id: "test")
        let options = [
            SelectionOption(label: .init(literal: "Opt 1"), value: "o1"),
            SelectionOption(label: .init(literal: "Opt 2"), value: "o2")
        ]
        let props = ChoicePickerProperties(
            label: .init(literal: "Pick many"),
            options: options,
            variant: .multipleSelection,
            value: .init(literal: ["o1"])
        )
        
        let view = A2UIChoicePickerView(id: "cp1", properties: props, surface: surface)
        
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let menu = try view.inspect().find(ViewType.Menu.self)
        XCTAssertNotNil(menu)
        
        // In multiple selection, it uses Menu and Toggles
        let toggles = try menu.findAll(ViewType.Toggle.self)
        XCTAssertEqual(toggles.count, 2)
        
        XCTAssertTrue(try toggles[0].isOn())
        XCTAssertFalse(try toggles[1].isOn())
    }
    
    @MainActor
    func testPickerWithDirectSurface() throws {
        let surface = SurfaceState(id: "test")
        let options = [SelectionOption(label: .init(literal: "Opt 1"), value: "o1")]
        let props = ChoicePickerProperties(label: .init(literal: "Label"), options: options, variant: .mutuallyExclusive, value: .init(literal: ["o1"]))
        
        let view = A2UIChoicePickerView(id: "cp1", properties: props, surface: surface)
        
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }

        let picker = try view.inspect().find(ViewType.Picker.self)
        XCTAssertNotNil(picker)
    }
}
