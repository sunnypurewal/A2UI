import Foundation
import A2UI

extension GalleryComponent {
	static let slider: Self = {
		return .init(
			id: "Slider",
			template: #"{"id":"gallery_component","component":{"Slider":{"value":{"path":"/value"},"min":0,"max":100}}}"#,
			staticComponents: [.root],
			dataModelFields: [
				.init(path: "/value", label: "Value", value: .number(50)),
			],
			properties: []
		)
	}()
}
