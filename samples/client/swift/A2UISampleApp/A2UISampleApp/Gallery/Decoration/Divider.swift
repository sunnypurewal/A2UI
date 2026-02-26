import Foundation
import A2UI

extension GalleryComponent {
	static let divider: Self = {
		return .init(
			id: "Divider",
			template: #"{"id":"gallery_component","component":{"Divider":{}}}"#,
			staticComponents: [.root],
			dataModelFields: [],
			properties: []
		)
	}()
}
