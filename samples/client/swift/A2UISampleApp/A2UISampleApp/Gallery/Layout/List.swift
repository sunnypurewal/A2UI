import Foundation
import A2UI

extension GalleryComponent {
	static let list: Self = {
		return .init(
			id: "List",
			template: #"{"id":"gallery_component","component":{"List":{"children":{"template":{"componentId":"card_content_container","path":"/items"}}}}}"#,
			staticComponents: [.root, .cardContentContainer, .cardContentTop, .cardContentBottom, .listH2, .listBody, .listCaption],
			dataModelFields: [
				.init(path: "/items", label: "Items (JSON array)", value: .listObjects((1...20).map { ["headline":"Headline \($0)","body":"Body text \($0)","caption":"Caption \($0)"] }))
			],
			properties: []
		)
	}()
}
