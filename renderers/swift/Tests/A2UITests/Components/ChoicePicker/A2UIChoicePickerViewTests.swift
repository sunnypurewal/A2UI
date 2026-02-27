import Testing
import SwiftUI
import ViewInspector
@testable import A2UI

@MainActor
struct A2UIChoicePickerViewTests {
    @Test func mutuallyExclusivePicker() throws {
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
        
        #expect(picker.findAll(ViewType.Text.self).count >= 2)
        
        try picker.select(value: "o2")
    }

    @Test func multipleSelectionPicker() throws {
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
        
        let toggles = menu.findAll(ViewType.Toggle.self)
        #expect(toggles.count == 2)
        
        #expect(try toggles[0].isOn())
        #expect(!(try toggles[1].isOn()))
    }
}
