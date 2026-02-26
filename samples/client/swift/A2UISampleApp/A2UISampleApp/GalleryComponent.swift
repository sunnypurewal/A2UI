import Foundation
import A2UI

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
	static let text: Self = {
		return .init(
			id: "Text",
			template: #"{"id":"gallery_component","component":{"Text":{"text":{"path":"/text"},"variant":"{{\#(variantKey)}}"}}}"#,
			staticComponents: [.root],
			dataModelFields: [
				.init(path: "/text", label: "Text", value: .string("Sample text")),
			],
			properties: [
				PropertyDefinition(key: variantKey, label: "Variant", options: A2UITextVariant.allCases.map { $0.rawValue }, value: A2UITextVariant.body.rawValue)
			]
		)
	}()
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
	static let video: Self = {
		return .init(
			id: "Video",
			template: #"{"id":"gallery_component","component":{"Video":{"url":{"path":"/url"}}}}"#,
			staticComponents: [.root],
			dataModelFields: [
				.init(path: "/url", label: "Video URL", value: .string("https://lorem.video/720p"))
			],
			properties: []
		)
	}()
	static let audioPlayer: Self = {
		return .init(
			id: "AudioPlayer",
			template: #"{"id":"gallery_component","component":{"AudioPlayer":{"url":{"path":"/url"}}}}"#,
			staticComponents: [.root],
			dataModelFields: [
				.init(path: "/url", label: "Video URL", value: .string("https://diviextended.com/wp-content/uploads/2021/10/sound-of-waves-marine-drive-mumbai.mp3"))
			],
			properties: []
		)
	}()
	static let icon: Self = {
		let nameKey = "name"
		let allIconNames = A2UIIconName.allCases.map { $0.rawValue }
		return .init(
			id: "Icon",
			template: #"{"id":"gallery_component","component":{"Icon":{"name":{"path":"/name"}}}}"#,
			staticComponents: [.root],
			dataModelFields: [
				.init(path: "/name", label: "Icon Name", value: .choice(A2UIIconName.search.rawValue, allIconNames))
			],
			properties: []
		)
	}()
}
