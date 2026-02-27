import XCTest
@testable import A2UI

final class A2UITextFieldPropertiesTests: XCTestCase {
    func testTextFieldVariantId() {
        XCTAssertEqual(TextFieldVariant.longText.rawValue, "longText")
        XCTAssertEqual(TextFieldVariant.number.rawValue, "number")
        XCTAssertEqual(TextFieldVariant.shortText.rawValue, "shortText")
        XCTAssertEqual(TextFieldVariant.obscured.rawValue, "obscured")
    }

    func testTextFieldPropertiesInit() {
        let label = BoundValue<String>(literal: "Test Label")
        let value = BoundValue<String>(literal: "Test Value")
        let props = TextFieldProperties(label: label, value: value, variant: .obscured)
        
        XCTAssertEqual(props.label.literal, "Test Label")
        XCTAssertEqual(props.value?.literal, "Test Value")
        XCTAssertEqual(props.variant, .obscured)
    }
}
