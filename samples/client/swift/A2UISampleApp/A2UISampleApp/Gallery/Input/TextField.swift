import Foundation
import A2UI

extension GalleryComponent {
	static let textField: Self = {
		return .init(
			id: "TextField",
			template: #"{"id":"gallery_component","component":{"TextField":{"text":{"path":"/text"},"placeholder":"Enter text...","type":"{{\#(textFieldTypeKey)}}"}}}"#,
			staticComponents: [.root],
			dataModelFields: [
				.init(path: "/text", label: "Text", value: .string("")),
			],
			properties: [
				PropertyDefinition(key: textFieldTypeKey, label: "Type", options: ["text", "password", "email", "number"], value: "text")
			]
		)
	}()
}
