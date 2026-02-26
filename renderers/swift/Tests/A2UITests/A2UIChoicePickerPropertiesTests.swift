import XCTest
@testable import A2UI

final class A2UIChoicePickerPropertiesTests: XCTestCase {
    func testChoicePickerVariantId() {
        XCTAssertEqual(ChoicePickerVariant.multipleSelection.id, "multipleSelection")
        XCTAssertEqual(ChoicePickerVariant.mutuallyExclusive.id, "mutuallyExclusive")
    }

    func testChoicePickerPropertiesInit() {
        let label = BoundValue<String>(literal: "Test Label")
        let options = [SelectionOption(label: BoundValue<String>(literal: "Opt 1"), value: "opt1")]
        let value = BoundValue<[String]>(literal: ["opt1"])
        
        let props = ChoicePickerProperties(label: label, options: options, variant: .mutuallyExclusive, value: value)
        
        XCTAssertEqual(props.label?.literal, "Test Label")
        XCTAssertEqual(props.options.count, 1)
        XCTAssertEqual(props.options[0].value, "opt1")
        XCTAssertEqual(props.variant, .mutuallyExclusive)
        XCTAssertEqual(props.value.literal, ["opt1"])
    }
}
