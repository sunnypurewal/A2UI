import Foundation
import A2UI

extension GalleryComponent {
	static let dateTimeInput: Self = {
		return .init(
			id: "DateTimeInput",
			template: #"{"id":"gallery_component","component":{"DateTimeInput":{"value":{"path":"/value"},"type":"date"}}}"#,
			staticComponents: [.root],
			dataModelFields: [
				.init(path: "/value", label: "Date", value: .string("2026-02-25")),
			],
			properties: []
		)
	}()
}
