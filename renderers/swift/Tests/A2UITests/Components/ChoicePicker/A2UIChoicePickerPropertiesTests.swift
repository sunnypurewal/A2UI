import Testing
@testable import A2UI

struct A2UIChoicePickerPropertiesTests {
    @Test func choicePickerVariantId() {
        #expect(ChoicePickerVariant.multipleSelection.id == "multipleSelection")
        #expect(ChoicePickerVariant.mutuallyExclusive.id == "mutuallyExclusive")
    }

    @Test func choicePickerPropertiesInit() {
        let label = BoundValue<String>(literal: "Test Label")
        let options = [SelectionOption(label: BoundValue<String>(literal: "Opt 1"), value: "opt1")]
        let value = BoundValue<[String]>(literal: ["opt1"])
        
        let props = ChoicePickerProperties(label: label, options: options, variant: .mutuallyExclusive, value: value)
        
        #expect(props.label?.literal == "Test Label")
        #expect(props.options.count == 1)
        #expect(props.options[0].value == "opt1")
        #expect(props.variant == .mutuallyExclusive)
        #expect(props.value.literal == ["opt1"])
    }
}
