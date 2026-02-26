import Foundation
import A2UI

extension GalleryComponent {
	static let slider: Self = {
		return .init(
			id: "Slider",
			template: #"{"id":"gallery_component","component":{"Slider":{"label":{"path":"/label"},"value":{"path":"/value"},"min":0,"max":100}}}"#,
			staticComponents: [.sliderRoot, .sliderPreview, .valueText],
			dataModelFields: [
				DataModelField(path: "/value", label: "Value", value: .number(50), showInEditor: false),
				DataModelField(path: "/label", label: "Label", value: .string("Slider")),
			],
			properties: [
	
			]
		)
	}()
}
