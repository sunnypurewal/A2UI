import Foundation
import A2UI

extension GalleryComponent {
	static let video: Self = {
		return .init(
			id: "Video",
			template: #"{"id":"gallery_component","component":{"Video":{"url":{"path":"/url"}}}}"#,
			staticComponents: [.root],
			dataModelFields: [
				.init(path: "/url", label: "Video URL", value: .string("https://lorem.video/720p"))
			],
			properties: []
		)
	}()
}
