import Foundation
import A2UI

extension GalleryComponent {
	static let checkbox: Self = {
		return .init(
			id: "CheckBox",
			template: #"{"id":"gallery_component","component":{"CheckBox":{"checked":{"path":"/checked"},"label":"Check me"}}}"#,
			staticComponents: [.root],
			dataModelFields: [
				.init(path: "/checked", label: "Checked", value: .bool(false)),
			],
			properties: []
		)
	}()
}
