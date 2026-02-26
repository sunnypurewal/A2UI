import Foundation
import A2UI

extension GalleryComponent {
	static let textField: Self = {
		return .init(
			id: "TextField",
			template: #"{"id":"gallery_component","checks":[{"condition":{"functionCall":{"call":"email","args":{"value":{"path":"/body/text"}}}},"message":"validation failed"}],"component":{"TextField":{"value":{"path":"/body/text"},"label":{"path":"/label"},"variant":"{{\#(textFieldVariantKey)}}"}}}"#,
			staticComponents: [.textFieldRoot, .body, .textFieldPreview],
			dataModelFields: [
				DataModelField(path: "/label", label: "Placeholder", value: .string("Enter text")),
				DataModelField(path: "/body/text", label: "", value: .string(""), showInEditor: false),
			],
			properties: [
				PropertyDefinition(key: textFieldVariantKey, label: "Type", options: TextFieldVariant.allCases.map(\.rawValue), value: TextFieldVariant.shortText.rawValue)
			]
		)
	}()
}
