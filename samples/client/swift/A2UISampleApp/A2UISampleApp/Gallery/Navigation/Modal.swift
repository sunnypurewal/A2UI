import Foundation
import A2UI

extension GalleryComponent {
	static let modal: Self = {
		return .init(
			id: "Modal",
			template: #"{"id":"gallery_component","component":{"Modal":{"child":"modal_content","isOpen":{"path":"/isOpen"}}}}"#,
			staticComponents: [.root, .modalContent],
			dataModelFields: [
				.init(path: "/isOpen", label: "Is Open", value: .bool(false)),
			],
			properties: []
		)
	}()
}
