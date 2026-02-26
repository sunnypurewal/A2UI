import Foundation
import A2UI

extension GalleryComponent {
	static let button: Self = {
		return .init(
			id: "Button",
			template: #"{"id":"gallery_component","component":{"Button":{"label":"Click Me","action":"button_clicked"}}}"#,
			staticComponents: [.root],
			dataModelFields: [],
			properties: []
		)
	}()
}
