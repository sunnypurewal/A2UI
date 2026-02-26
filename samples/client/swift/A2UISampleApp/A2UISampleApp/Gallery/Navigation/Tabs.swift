import Foundation
import A2UI

extension GalleryComponent {
	static let tabs: Self = {
		return .init(
			id: "Tabs",
			template: #"{"id":"gallery_component","component":{"Tabs":{"tabs":[{"title":"Tab 1","child":"tab1_content"},{"title":"Tab 2","child":"tab2_content"}]}}}"#,
			staticComponents: [.root, .tab1, .tab2],
			dataModelFields: [],
			properties: []
		)
	}()
}
