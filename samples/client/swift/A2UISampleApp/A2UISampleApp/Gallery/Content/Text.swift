import Foundation
import A2UI

extension GalleryComponent {
	static let text: Self = {
		return .init(
			id: "Text",
			template: #"{"id":"gallery_component","component":{"Text":{"text":{"path":"/text"},"variant":"{{\#(variantKey)}}"}}}"#,
			staticComponents: [.root],
			dataModelFields: [
				.init(path: "/text", label: "Text", value: .string("Sample text")),
			],
			properties: [
				PropertyDefinition(key: variantKey, label: "Variant", options: A2UITextVariant.allCases.map { $0.rawValue }, value: A2UITextVariant.body.rawValue)
			]
		)
	}()
}
