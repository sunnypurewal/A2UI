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
            (.video(VideoProperties(url: .init(literal: ""))), "Video"),
            (.audioPlayer(AudioPlayerProperties(url: .init(literal: ""))), "AudioPlayer"),
            (.custom("MyComp", [:]), "MyComp")
        ]
        
        for (type, expectedName) in cases {
            XCTAssertEqual(type.typeName, expectedName)
        }
    }

    func testComponentTypeCodableRoundTrip() throws {
        let cases: [ComponentType] = [
            .text(TextProperties(text: .init(literal: "hello"), variant: .h1)),
            .button(ButtonProperties(child: "c1", action: .custom(name: "tap", context: nil))),
            .column(ContainerProperties(children: .list(["a"]), justify: .center, align: .center)),
            .row(ContainerProperties(children: .list(["b"]), justify: .start, align: .end)),
            .card(CardProperties(child: "c1")),
            .divider(DividerProperties(axis: .vertical)),
            .image(ImageProperties(url: .init(literal: "url"), fit: .contain, variant: nil)),
            .list(ListProperties(children: .list([]), direction: "horizontal", align: "center")),
            .textField(TextFieldProperties(label: .init(literal: "l"), value: .init(path: "p"))),
            .choicePicker(ChoicePickerProperties(label: .init(literal: "l"), options: [], value: .init(path: "p"))),
            .dateTimeInput(DateTimeInputProperties(label: .init(literal: "l"), value: .init(path: "p"))),
            .slider(SliderProperties(label: .init(literal: "l"), min: 0, max: 100, value: .init(path: "p"))),
            .checkBox(CheckBoxProperties(label: .init(literal: "l"), value: .init(path: "p"))),
            .tabs(TabsProperties(tabs: [])),
            .icon(IconProperties(name: .init(literal: "star"))),
            .modal(ModalProperties(trigger: "t1", content: "c1")),
            .video(VideoProperties(url: .init(literal: "v"))),
            .audioPlayer(AudioPlayerProperties(url: .init(literal: "a"))),
            .custom("MyComp", ["foo": AnyCodable("bar")])
        ]

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for original in cases {
            let data = try encoder.encode(original)
            let decoded = try decoder.decode(ComponentType.self, from: data)
            XCTAssertEqual(original.typeName, decoded.typeName)
            
            // Re-encode to ensure consistency
            let reEncoded = try encoder.encode(decoded)
            // We can't always compare data directly because of dictionary ordering or other factors,
            // but for these simple cases it usually works or we can decode again.
            let reDecoded = try decoder.decode(ComponentType.self, from: reEncoded)
            XCTAssertEqual(original.typeName, reDecoded.typeName)
        }
    }

    func testDecodingInvalidComponentType() {
        let json = "{}" // Missing keys
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        XCTAssertThrowsError(try decoder.decode(ComponentType.self, from: data))
    }
}
