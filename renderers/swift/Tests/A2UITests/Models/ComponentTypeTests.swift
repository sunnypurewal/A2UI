import XCTest
@testable import A2UI

final class ComponentTypeTests: XCTestCase {
    func testComponentTypeNames() {
        let cases: [(ComponentType, String)] = [
            (.text(TextProperties(text: .init(literal: ""), variant: nil)), "Text"),
            (.button(ButtonProperties(child: "c1", action: .custom(name: "", context: nil))), "Button"),
            (.column(ContainerProperties(children: .list([]), justify: nil, align: nil)), "Column"),
            (.row(ContainerProperties(children: .list([]), justify: nil, align: nil)), "Row"),
            (.card(CardProperties(child: "c1")), "Card"),
            (.divider(DividerProperties(axis: .horizontal)), "Divider"),
            (.image(ImageProperties(url: .init(literal: ""), fit: nil, variant: nil)), "Image"),
            (.list(ListProperties(children: .list([]), direction: nil, align: nil)), "List"),
            (.textField(TextFieldProperties(label: .init(literal: ""), value: .init(path: "p"))), "TextField"),
            (.choicePicker(ChoicePickerProperties(label: .init(literal: ""), options: [], value: .init(path: "p"))), "ChoicePicker"),
            (.dateTimeInput(DateTimeInputProperties(label: .init(literal: ""), value: .init(path: "p"))), "DateTimeInput"),
            (.slider(SliderProperties(label: .init(literal: ""), min: 0, max: 100, value: .init(path: "p"))), "Slider"),
            (.checkBox(CheckBoxProperties(label: .init(literal: ""), value: .init(path: "p"))), "CheckBox"),
            (.tabs(TabsProperties(tabs: [])), "Tabs"),
            (.icon(IconProperties(name: .init(literal: "star"))), "Icon"),
            (.modal(ModalProperties(trigger: "t1", content: "c1")), "Modal"),
            (.custom("MyComp", [:]), "MyComp")
        ]
        
        for (type, expectedName) in cases {
            XCTAssertEqual(type.typeName, expectedName)
        }
    }
}
