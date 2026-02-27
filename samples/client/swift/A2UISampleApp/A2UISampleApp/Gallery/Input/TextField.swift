import Foundation
import A2UI

extension GalleryComponent {
	static let textField: Self = {
		let functions: [StandardCheckFunction] = [.email, .required]
		return .init(
			id: "TextField",
			template: #"{"id":"gallery_component","checks":[{{\#(checkFunctionKey)}}],"component":{"TextField":{"value":{"path":"/body/text"},"label":{"path":"/label"},"variant":"{{\#(textFieldVariantKey)}}"}}}"#,
			staticComponents: [.textFieldRoot, .body, .textFieldPreview],
			dataModelFields: [
				DataModelField(path: "/label", label: "Placeholder", value: .string("Enter text")),
				DataModelField(path: "/body/text", label: "", value: .string(""), showInEditor: false),
			],
			properties: [
				PropertyDefinition(key: textFieldVariantKey, label: "Type", options: TextFieldVariant.allCases.map(\.rawValue), value: TextFieldVariant.shortText.rawValue),
				PropertyDefinition(
					key: checkFunctionKey,
					label: "Check",
					options: ["None"] + functions.map(\.rawValue),
					value: "None",
					mapValue: { value in
						guard let funcName = value, funcName != "None" else { return "" }
						return #"{"condition":{"call":"\#(funcName)","args":{"value":{"path":"/body/text"}}},"message":"Validation failed"}"#
					}
				)
			]
		)
	}()
}
