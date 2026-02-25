import Foundation
import A2UI

struct DataModelField: Identifiable {
	enum Value {
		case string(String)
		case number(Double)
		case bool(Bool)
		case listObjects([[String: Any]])
	}
	
	let id = UUID()
	let path: String
	let label: String
	var value: Value
	
	func updateDataModelA2UI(surfaceId: String) -> String {
		let valueJson: String
		switch value {
		case .string(let stringValue):
			valueJson = jsonLiteral(from: stringValue)
		case .number(let numberValue):
			valueJson = "\(numberValue)"
		case .bool(let boolValue):
			valueJson = boolValue ? "true" : "false"
		case .listObjects(let listValue):
			valueJson = jsonArrayLiteral(from: listValue)
		}
		return #"{"version":"v0.10","updateDataModel":{"surfaceId":"\#(surfaceId)","path":"\#(path)","value":\#(valueJson)}}"#
	}

	private func jsonLiteral(from stringValue: String) -> String {
		if let data = stringValue.data(using: .utf8),
		   let object = try? JSONSerialization.jsonObject(with: data),
		   JSONSerialization.isValidJSONObject(object),
		   let jsonData = try? JSONSerialization.data(withJSONObject: object),
		   let jsonString = String(data: jsonData, encoding: .utf8) {
			return jsonString
		}

		guard let data = try? JSONSerialization.data(withJSONObject: [stringValue]),
			  let wrapped = String(data: data, encoding: .utf8),
			  wrapped.count >= 2 else {
			return "\"\""
		}

		return String(wrapped.dropFirst().dropLast())
	}

	private func jsonArrayLiteral(from listValue: [[String: Any]]) -> String {
		guard JSONSerialization.isValidJSONObject(listValue),
			  let jsonData = try? JSONSerialization.data(withJSONObject: listValue),
			  let jsonString = String(data: jsonData, encoding: .utf8) else {
			return "[]"
		}
		return jsonString
	}
}

struct GalleryData {
	static var all: [ComponentCategory: [String: GalleryComponent]] = [
		.layout: [
			"Row": .row,
			"Column": .column,
			"List": .list,
		]
	]
}

struct GalleryComponent: Identifiable {
	let id: String
	let template: String
	let staticComponents: [StaticComponent]
	var dataModelFields: [DataModelField]
	var canEditDataModel: Bool {
		return !dataModelFields.isEmpty && id != "List"
	}
	var properties: [PropertyDefinition]
	var canEditProperties: Bool {
		return !properties.isEmpty
	}
	
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
		let dataModelUpdates = dataModelFields.map { $0.updateDataModelA2UI(surfaceId: id) }
		return ([createSurfaceA2UI, updateComponentsA2UI] + dataModelUpdates)
			.joined(separator: "\n")
	}
	
	var createSurfaceA2UI: String {
		return #"{"version":"v0.10","createSurface":{"surfaceId":"\#(id)","catalogId":"a2ui.org:standard_catalog"}}"#
	}
	var updateComponentsA2UI: String {
		return #"{"version":"v0.10","updateComponents":{"surfaceId":"\#(id)","components":[\#(resolvedComponents.joined(separator: ","))]}}"#
	}
	
	var resolvedComponents: [String] {
		return [resolvedTemplate] + staticComponents.map { $0.rawValue } 
	}
	
	var prettyJson: String {
		let objects: [Any] = resolvedComponents.compactMap { json in
			guard let data = json.data(using: .utf8) else { return nil }
			return try? JSONSerialization.jsonObject(with: data)
		}
		guard !objects.isEmpty else { return "[]" }
		let options: JSONSerialization.WritingOptions = [.prettyPrinted, .sortedKeys]
		guard let data = try? JSONSerialization.data(withJSONObject: objects, options: options),
			  let pretty = String(data: data, encoding: .utf8) else {
			return "[\n\(resolvedComponents.joined(separator: ",\n"))\n]"
		}
		return pretty
	}
}

extension GalleryComponent {
	/// Layout
	static let row: Self = {
		return .init(
			id: "Row",
			template: #"{"id":"gallery_component","component":{"Row":{"children":["t_h2","t_body","t_caption"],"justify":"{{\#(justifyKey)}}","align":"{{\#(alignKey)}}"}}}"#,
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
//	static let card: Self = {
	//		return .init(
	//			id: "Card",
	//			template: #"{"id":"gallery_component","component":{"Card":{"child":"card_content_container"}}}"#,
	//			staticComponents: [.root, .cardContentContainer, .cardContentTop, .cardContentBottom, .h2, .body, .caption],
	//			dataModelFields: [],
	//			properties: []
	//		)
	//	}()
	static let list: Self = {
			return .init(
				id: "List",
				template: #"{"id":"gallery_component","component":{"List":{"children":{"template":{"componentId":"card_content_container","path":"/items"}}}}}"#,
				staticComponents: [.root, .cardContentContainer, .cardContentTop, .cardContentBottom, .listH2, .listBody, .listCaption],
				dataModelFields: [
					.init(path: "/items", label: "Items (JSON array)", value: .listObjects((1...20).map { ["headline":"Headline \($0)","body":"Body text \($0)","caption":"Caption \($0)"] }))
				],
				properties: []
			)
		}()
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

enum StaticComponent: String {
	case h2 = #"{"id":"t_h2","component":{"Text":{"text":{"path":"/headline/text"},"variant":"h2"}}}"#
	case body = #"{"id":"t_body","component":{"Text":{"text":{"path":"/body/text"},"variant":"body"}}}"#
	case caption = #"{"id":"t_caption","component":{"Text":{"text":{"path":"/caption/text"},"variant":"caption"}}}"#
	case root = #"{"id":"root","component":{"Card":{"child":"gallery_component"}}}"#
	case cardContentContainer = #"{"id":"card_content_container","component":{"Column":{"children":["card_content_top","card_content_bottom"],"justify":"spaceAround","align":"center"}}}"#
	case cardContentTop = #"{"id":"card_content_top","component":{"Row":{"children":["t_h2"],"justify":"start","align":"center"}}}"#
	case cardContentBottom = #"{"id":"card_content_bottom","component":{"Row":{"children":["t_body","t_caption"],"justify":"spaceBetween","align":"center"}}}"#
	case listH2 = #"{"id":"t_h2","component":{"Text":{"text":{"path":"headline"},"variant":"h2"}}}"#
	case listBody = #"{"id":"t_body","component":{"Text":{"text":{"path":"body"},"variant":"body"}}}"#
	case listCaption = #"{"id":"t_caption","component":{"Text":{"text":{"path":"caption"},"variant":"caption"}}}"#
}
