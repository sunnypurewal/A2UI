import Foundation
import A2UI

extension GalleryComponent {
	static let button: Self = {
		return .init(
			id: "Button",
			template: #"{"id":"gallery_component","component":{"Button":{"child":"button_child","action":{"functionCall":{"call": "button_click"}}}}}"#,
			staticComponents: [.root, .buttonChild],
			dataModelFields: [],
			properties: []
		)
	}()
}
