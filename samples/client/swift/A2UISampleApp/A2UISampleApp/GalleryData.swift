import Foundation
import A2UI

struct GalleryData {
    struct Section: Identifiable {
        let id = UUID()
		let name: String
		let subsections: [SubSection]
    }
	
	struct SubSection: Identifiable {
		let id: String
		let template: String
		let staticComponents: [String]
		var properties: [PropertyDefinition]
		
		var a2ui: String {
			return [createSurfaceA2UI, updateComponentsA2UI].joined(separator: "\n")
		}
		
		var createSurfaceA2UI: String {
			return #"{"version":"v0.10","createSurface":{"surfaceId":"\#(id)","catalogId":"a2ui.org:standard_catalog"}}"#
		}
		var updateComponentsA2UI: String {
			return #"{"version":"v0.10","updateComponents":{"surfaceId":"\#(id)","components":[\#(resolvedComponents.joined(separator: ","))]}}"#
		}
		
		var resolvedComponents: [String] {
			var comp = template
			for prop in properties {
				comp = comp.replacingOccurrences(of: "{{\(prop.key)}}", with: prop.value)
			}
			return staticComponents + [comp]
		}
		
		var prettyJson: String {
			var comp = template
			for prop in properties {
				comp = comp.replacingOccurrences(of: "{{\(prop.key)}}", with: prop.value)
			}
			let entries = [comp]
			return "[\n\(entries)\n]"
		}
	}

	struct PropertyDefinition: Identifiable {
		var id: String { key }
		let key: String
		let label: String
		let options: [String]
		var value: String
	}

    static let sections: [Section] = [
		Section(name: "Layout", subsections: [
			SubSection(
				id: "Row",
				template: #"{"id":"gallery_component","component":{"Row":{"children":["t_h2","t_body","t_caption"],"justify":"{{\#(justifyKey)}}","align":"{{\#(alignKey)}}"}}}"#,
				staticComponents: [root, h2, body, caption],
				properties: [
					PropertyDefinition(key: justifyKey, label: "Justify", options: A2UIJustify.allCases.map { $0.rawValue }, value: A2UIJustify.start.rawValue),
					PropertyDefinition(key: alignKey, label: "Align", options: A2UIAlign.allCases.map { $0.rawValue }, value: A2UIAlign.start.rawValue)
				]
			),
			SubSection(
				id: "Column",
				template: #"{"id":"gallery_component","component":{"Column":{"children":["t_h2","t_body","t_caption"],"justify":"{{\#(justifyKey)}}","align":"{{\#(alignKey)}}"}}}"#,
				staticComponents: [root, h2, body, caption],
				properties: [
					PropertyDefinition(key: justifyKey, label: "Justify", options: A2UIJustify.allCases.map { $0.rawValue }, value: A2UIJustify.start.rawValue),
					PropertyDefinition(key: alignKey, label: "Align", options: A2UIAlign.allCases.map { $0.rawValue }, value: A2UIAlign.start.rawValue)
				]
			)
		]),
	]
	
	static let justifyKey = "justify"
	static let alignKey = "align"
	static let textAlignKey = "textAlign"
	static let colorKey = "color"
}

let h2 = #"{"id":"t_h2","component":{"Text":{"text":"h2","variant":"h2"}}}"#
let body = #"{"id":"t_body","component":{"Text":{"text":"body","variant":"body"}}}"#
let caption = #"{"id":"t_caption","component":{"Text":{"text":"caption","variant":"caption"}}}"#
let root = #"{"id":"root","component":{"Card":{"child":"gallery_component"}}}"#
