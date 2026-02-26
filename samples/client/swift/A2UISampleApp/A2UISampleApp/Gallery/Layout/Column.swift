import Foundation
import A2UI

extension GalleryComponent {
	static let column: Self = {
		return .init(
			id: "Column",
			template: #"{"id":"gallery_component","component":{"Column":{"children":["t_h2","t_body","t_caption"],"justify":"{{\#(justifyKey)}}","align":"{{\#(alignKey)}}"}}}"#,
			staticComponents: [.root, .h2, .body, .caption],
			dataModelFields: [
				.init(path: "/headline/text", label: "Headline", value: .string("Headline")),
				.init(path: "/body/text", label: "Body", value: .string("Body text")),
				.init(path: "/caption/text", label: "Caption", value: .string("Caption"))
			],
			properties: [
				PropertyDefinition(key: justifyKey, label: "Justify", options: A2UIJustify.allCases.map { $0.rawValue }, value: A2UIJustify.start.rawValue),
				PropertyDefinition(key: alignKey, label: "Align", options: A2UIAlign.allCases.map { $0.rawValue }, value: A2UIAlign.start.rawValue)
			]
		)
	}()
}
