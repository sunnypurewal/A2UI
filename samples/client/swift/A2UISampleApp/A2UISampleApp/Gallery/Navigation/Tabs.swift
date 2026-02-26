import Foundation
import A2UI

extension GalleryComponent {
	static let tabs: Self = {
		return .init(
			id: "Tabs",
			template: #"{"id":"gallery_component","component":{"Tabs":{"children":["tab1_content","tab2_content"],"selection":{"path":"/tab"}}}}"#,
			staticComponents: [.root, .tab1, .tab2],
			dataModelFields: [
				.init(path: "/tab", label: "Selected Tab", value: .number(0)),
			],
			properties: []
		)
	}()
}
