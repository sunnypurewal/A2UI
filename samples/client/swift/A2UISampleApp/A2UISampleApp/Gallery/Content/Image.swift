import Foundation
import A2UI

extension GalleryComponent {
	static let image: Self = {
		return .init(
			id: "Image",
			template: #"{"id":"gallery_component","component":{"Image":{"url":{"path":"/url"},"variant":"{{\#(variantKey)}}","fit":"{{\#(fitKey)}}"}}}"#,
			staticComponents: [.root],
			dataModelFields: [
				.init(path: "/url", label: "Image URL", value: .string("https://picsum.photos/200"))
			],
			properties: [
				PropertyDefinition(key: variantKey, label: "Variant", options: A2UIImageVariant.allCases.map { $0.rawValue }, value: A2UIImageVariant.icon.rawValue),
				PropertyDefinition(key: fitKey, label: "Fit", options: A2UIImageFit.allCases.map { $0.rawValue }, value: A2UIImageFit.contain.rawValue)
			]
		)
	}()
}
