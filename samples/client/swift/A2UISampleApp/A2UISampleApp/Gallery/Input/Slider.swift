import Foundation
import A2UI

extension GalleryComponent {
	static let slider: Self = {
		return .init(
			id: "Slider",
			template: #"{"id":"gallery_component","component":{"Slider":{"label":{"path":"/label"},"value":{"path":"/value"},"min":{{\#(minKey)}},"max":{{\#(maxKey)}}}}}"#,
			staticComponents: [.sliderRoot, .sliderPreview, .valueText],
			dataModelFields: [
				DataModelField(path: "/value", label: "Value", value: .number(50), showInEditor: false),
				DataModelField(path: "/label", label: "Label", value: .string("Slider")),
			],
			properties: [
				PropertyDefinition(key: minKey, label: "Min", value: "0", minValue: 0, maxValue: 50),
				PropertyDefinition(key: maxKey, label: "Max", value: "100", minValue: 51, maxValue: 200)
			]
		)
	}()
}
