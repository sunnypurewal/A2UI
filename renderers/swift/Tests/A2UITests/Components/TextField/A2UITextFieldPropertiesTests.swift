import Testing
@testable import A2UI

struct A2UITextFieldPropertiesTests {
    @Test func textFieldVariantId() {
        #expect(TextFieldVariant.longText.id == "longText")
        #expect(TextFieldVariant.number.id == "number")
        #expect(TextFieldVariant.shortText.id == "shortText")
        #expect(TextFieldVariant.obscured.id == "obscured")
    }

    @Test func textFieldPropertiesInit() {
        let label = BoundValue<String>(literal: "Test Label")
        let value = BoundValue<String>(literal: "Test Value")
        let props = TextFieldProperties(label: label, value: value, variant: .obscured)
        
        #expect(props.label.literal == "Test Label")
        #expect(props.value?.literal == "Test Value")
        #expect(props.variant == .obscured)
    }
}
