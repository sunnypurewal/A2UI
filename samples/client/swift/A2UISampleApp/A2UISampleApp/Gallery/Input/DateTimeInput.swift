import Foundation
import A2UI

extension GalleryComponent {
	static let dateTimeInput: Self = {
		return .init(
			id: "DateTimeInput",
			template: #"{"id":"gallery_component","component":{"DateTimeInput":{"value":{"path":"/value"},"label":{"path":"/label"},"enableDate":{{\#(enableDateKey)}},"enableTime":{{\#(enableTimeKey)}}}}}"#,
			staticComponents: [.root],
			dataModelFields: [
				DataModelField(path: "/value", label: "Date", value: .string(""), showInEditor: false),
				DataModelField(path: "/label", label: "Label", value: .string("DateTime")),
			],
			properties: [
				PropertyDefinition(key: enableDateKey, label: "Show Date", value: "true", isBoolean: true),
				PropertyDefinition(key: enableTimeKey, label: "Show Time", value: "true", isBoolean: true)
			]
		)
	}()
}
