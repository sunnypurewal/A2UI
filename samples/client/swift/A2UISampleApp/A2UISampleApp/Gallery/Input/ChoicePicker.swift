import Foundation
import A2UI

extension GalleryComponent {
	static let choicePicker: Self = {
		return .init(
			id: "ChoicePicker",
			template: #"{"id":"gallery_component","component":{"ChoicePicker":{"selection":{"path":"/selection"},"options":["Option 1","Option 2","Option 3"]}}}"#,
			staticComponents: [.root],
			dataModelFields: [
				.init(path: "/selection", label: "Selected", value: .string("Option 1")),
			],
			properties: []
		)
	}()
}
