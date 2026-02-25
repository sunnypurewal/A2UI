import Foundation

struct GalleryData {
    struct Section: Identifiable {
        let id = UUID()
		let name: String
		let subsections: [SubSection]
    }
	
	struct SubSection: Identifiable {
		let id: String
		let components: [String]
		
		var a2ui: String {
			let createSurfaceLine = #"{"version":"v0.10","createSurface":{"surfaceId":"\#(id)","catalogId":"a2ui.org:standard_catalog"}}"#
			let updateComponentsLine = #"{"version":"v0.10","updateComponents":{"surfaceId":"\#(id)","components":[\#(components.joined(separator: ","))]}}"#
			return [createSurfaceLine, updateComponentsLine].joined(separator: "\n")
		}
		
		var prettyJson: String {
			let entries = components.map { "    \($0)" }.joined(separator: ",\n")
			return "[\n\(entries)\n]"
		}
	}

    static let sections: [Section] = [
		Section(name: "Layout", subsections: [
			SubSection(id: "Row", components: [
				root,
				row,
				h2,
				body,
				caption
			])
		])
	]
}

let h2 = #"{"id":"t_h2","component":{"Text":{"text":"h2","variant":"h2"}}}"#
let body = #"{"id":"t_body","component":{"Text":{"text":"body","variant":"body"}}}"#
let caption = #"{"id":"t_caption","component":{"Text":{"text":"caption","variant":"caption"}}}"#
let root = #"{"id":"root","component":{"Card":{"child":"gallery_component"}}}"#
let row = #"{"id":"gallery_component","component":{"Row":{"children":{"explicitList":["t_h2","t_body","t_caption"]},"justify":"start","align":"start"}}}"#
