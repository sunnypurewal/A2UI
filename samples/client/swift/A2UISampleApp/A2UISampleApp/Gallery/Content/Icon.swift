import Foundation
import A2UI

extension GalleryComponent {
	static let icon: Self = {
		let allIconNames = A2UIIconName.allCases.map { $0.rawValue }
		return .init(
			id: "Icon",
			template: #"{"id":"gallery_component","component":{"Icon":{"name":{"path":"/name"}}}}"#,
			staticComponents: [.root],
			dataModelFields: [
				.init(path: "/name", label: "Icon Name", value: .choice(A2UIIconName.search.rawValue, allIconNames))
			],
			properties: []
		)
	}()
}
