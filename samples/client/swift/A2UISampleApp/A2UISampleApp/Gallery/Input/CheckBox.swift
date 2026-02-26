import Foundation
import A2UI

extension GalleryComponent {
	static let checkbox: Self = {
		return .init(
			id: "CheckBox",
			template: #"{"id":"gallery_component","component":{"CheckBox":{"value":{"path":"/value"},"label":{"path":"/label"}}}}"#,
			staticComponents: [.checkboxRoot, .checkboxValue, .checkboxPreview],
			dataModelFields: [
				DataModelField(path: "/label", label: "Label", value: .string("Toggle")),
				DataModelField(path: "/value", label: "", value: .bool(false), showInEditor: false)
			],
			properties: []
		)
	}()
}
