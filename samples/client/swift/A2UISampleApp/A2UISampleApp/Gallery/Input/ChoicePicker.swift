import Foundation
import A2UI

extension GalleryComponent {
	var options: [[String:Any]] {
		[
			[
				"label": "Option 1",
				"value": "option1"
			],
			[
				"label": "Option 2",
				"value": "option2"
			],
			[
				"label": "Option 3",
				"value": "option3"
			]
		]
	}
	static let choicePicker: Self = {
		return .init(
			id: "ChoicePicker",
			template: #"{"id":"gallery_component","component":{"ChoicePicker":{"label":{"path":"/label"},"variant":"{{\#(choicePickerVariantKey)}}","options":[{"label":{"path":"/options/0/label"},"value":"option1"},{"label":{"path":"/options/1/label"},"value":"option2"},{"label":{"path":"/options/2/label"},"value":"option3"}],"value":{"path":"/value"}}}}"#,
			staticComponents: [.choicePickerRoot, .choicePickerPreview, .valueText],
			dataModelFields: [
				DataModelField(path: "/options", label: "Options", value: .listObjects([
					[
						"label": "Option 1",
						"value": "option1"
					],
					[
						"label": "Option 2",
						"value": "option2"
					],
					[
						"label": "Option 3",
						"value": "option3"
					]
				]), showInEditor: false),
				DataModelField(path: "/value", label: "Selected", value: .listObjects([]), showInEditor: false),
				DataModelField(path: "/label", label: "Label", value: .string("Picker"))
				
			],
			properties: [
				PropertyDefinition(key: choicePickerVariantKey, label: "Type", options: ChoicePickerVariant.allCases.map(\.rawValue), value: ChoicePickerVariant.mutuallyExclusive.rawValue)
			]
		)
	}()
}
