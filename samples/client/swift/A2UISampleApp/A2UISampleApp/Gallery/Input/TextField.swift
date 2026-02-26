import Foundation
import A2UI

extension GalleryComponent {
	static let textField: Self = {
		let p = [
			PropertyDefinition(key: textFieldVariantKey, label: "Type", options: TextFieldVariant.allCases.map(\.rawValue), value: TextFieldVariant.shortText.rawValue),
			PropertyDefinition(key: checkFunctionKey, label: "Check", options: StandardCheckFunction.allCases.map(\.rawValue), value: StandardCheckFunction.email.rawValue)
		]
		let checksTemplate = p.contains(where: { $0.key == checkFunctionKey }) ? #"[{"condition":{"call":"{{\#(checkFunctionKey)}}","args":{"value":{"path":"/body/text"},"pattern":"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$","min":3,"max":10}},"message":"Validation failed"}]"# : "[]"
		return .init(
			id: "TextField",
			template: #"{"id":"gallery_component","checks":,"component":{"TextField":{"value":{"path":"/body/text"},"label":{"path":"/label"},"variant":"{{\#(textFieldVariantKey)}}"}}}"#,
			staticComponents: [.textFieldRoot, .body, .textFieldPreview],
			dataModelFields: [
				DataModelField(path: "/label", label: "Placeholder", value: .string("Enter text")),
				DataModelField(path: "/body/text", label: "", value: .string(""), showInEditor: false),
			],
			properties: p
		)
	}()
}
