import Foundation
import A2UI

extension GalleryComponent {
	static let modal: Self = {
		return .init(
			id: "Modal",
			template: #"{"id":"gallery_component","component":{"Modal":{"content":"modal_content","trigger":"trigger_button"}}}"#,
			staticComponents: [.root, .modalContent, .modalButton, .buttonChild],
			dataModelFields: [],
			properties: []
		)
	}()
}
