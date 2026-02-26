import Foundation
import A2UI

extension GalleryComponent {
	static let divider: Self = {
		return .init(
			id: "Divider",
			template: #"{"id":"gallery_component","component":{"Divider":{}}}"#,
			staticComponents: [.dividerRow, .dividerRoot, .dividerColumn, .dividerContainer, .body],
			dataModelFields: [
				DataModelField(path: "/body/text", label: "Text", value: .string("Text"))
			],
			properties: []
		)
	}()
}
