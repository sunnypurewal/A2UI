import Foundation
import A2UI

struct GalleryData {
	static var all: [ComponentCategory: [String: GalleryComponent]] = [
		.layout: [
			"Row": .row,
			"Column": .column
		]
	]
}

struct GalleryComponent: Identifiable {
	let id: String
	let template: String
	let staticComponents: [String]
	var properties: [PropertyDefinition]
	
	static let row: Self = {
		return .init(
			id: "Row",
			template: #"{"id":"gallery_component","component":{"Row":{"children":["t_h2","t_body","t_caption"],"justify":"{{\#(justifyKey)}}","align":"{{\#(alignKey)}}"}}}"#,
			staticComponents: [root, h2, body, caption],
			properties: [
				PropertyDefinition(key: justifyKey, label: "Justify", options: A2UIJustify.allCases.map { $0.rawValue }, value: A2UIJustify.start.rawValue),
				PropertyDefinition(key: alignKey, label: "Align", options: A2UIAlign.allCases.map { $0.rawValue }, value: A2UIAlign.start.rawValue)
			]
		)
	}()
	
	static let column: Self = {
		return .init(
			id: "Column",
			template: #"{"id":"gallery_component","component":{"Column":{"children":["t_h2","t_body","t_caption"],"justify":"{{\#(justifyKey)}}","align":"{{\#(alignKey)}}"}}}"#,
			staticComponents: [root, h2, body, caption],
			properties: [
				PropertyDefinition(key: justifyKey, label: "Justify", options: A2UIJustify.allCases.map { $0.rawValue }, value: A2UIJustify.start.rawValue),
				PropertyDefinition(key: alignKey, label: "Align", options: A2UIAlign.allCases.map { $0.rawValue }, value: A2UIAlign.start.rawValue)
			]
		)
	}()
	
	mutating func setProperty(_ key: String, to value: String) {
		guard let index = properties.firstIndex(where: { $0.key == key }) else { return }
		properties[index].value = value
	}
	
	var resolvedTemplate: String {
		var comp = template
		for prop in properties {
			comp = comp.replacingOccurrences(of: "{{\(prop.key)}}", with: prop.value)
		}
		return comp
	}
	
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
		return staticComponents + [resolvedTemplate]
	}
	
	var prettyJson: String {
		guard let data = resolvedTemplate.data(using: .utf8) else { return "{}" }
		do {
			let obj = try JSONSerialization.jsonObject(with: data)
			let options: JSONSerialization.WritingOptions = [.prettyPrinted, .sortedKeys]
			guard let prettyData = try? JSONSerialization.data(withJSONObject: obj, options: options),
				  let prettyString = String(data: prettyData, encoding: .utf8) else {
				return resolvedTemplate
			}
			return prettyString
		} catch {
			return "{}"
		}
	}
}

struct PropertyDefinition: Identifiable {
	var id: String { key }
	let key: String
	let label: String
	let options: [String]
	var value: String
}

let justifyKey = "justify"
let alignKey = "align"
let textAlignKey = "textAlign"
let colorKey = "color"

let h2 = #"{"id":"t_h2","component":{"Text":{"text":"h2","variant":"h2"}}}"#
let body = #"{"id":"t_body","component":{"Text":{"text":"body","variant":"body"}}}"#
let caption = #"{"id":"t_caption","component":{"Text":{"text":"caption","variant":"caption"}}}"#
let root = #"{"id":"root","component":{"Card":{"child":"gallery_component"}}}"#
