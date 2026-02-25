import Foundation

struct GalleryData {
    struct Section: Identifiable {
        let id = UUID()
        let name: String
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
		Section(name: "Layout", components: [
			#"{"id":"root","component":{"Card":{"child":"root_col"}}}"#,
			#"{"id":"root_col","component":{"Row":{"children":{"explicitList":["t_h2","t_body","t_caption"]}}}}"#,
			#"{"id":"t_h2","component":{"Text":{"text":"Left","variant":"h2"}}}"#,
			#"{"id":"t_body","component":{"Text":{"text":"Centre","variant":"body"}}}"#,
			#"{"id":"t_caption","component":{"Text":{"text":"Right","variant":"caption"}}}"#
		])
//        Section(name: "Typography", components: [
//            #"{"id":"root","component":{"Card":{"child":"root_col"}}}"#,
//            #"{"id":"root_col","component":{"Column":{"children":{"explicitList":["t_h2","t_body","t_caption"]}}}}"#,
//            #"{"id":"t_h2","component":{"Text":{"text":"Typography","variant":"h2"}}}"#,
//            #"{"id":"t_body","component":{"Text":{"text":"This is a body text showing how standard text renders.","variant":"body"}}}"#,
//            #"{"id":"t_caption","component":{"Text":{"text":"This is a caption text.","variant":"caption"}}}"#
//        ]),
//        Section(name: "Buttons", components: [
//            #"{"id":"root","component":{"Card":{"child":"root_col"}}}"#,
//            #"{"id":"root_col","component":{"Column":{"children":{"explicitList":["b_h2","b_row"]}}}}"#,
//            #"{"id":"b_h2","component":{"Text":{"text":"Buttons","variant":"h2"}}}"#,
//            #"{"id":"b_row","component":{"Row":{"children":{"explicitList":["b1","b2"]}}}}"#,
//            #"{"id":"b1_label","component":{"Text":{"text":"Primary"}}}"#,
//            #"{"id":"b1","component":{"Button":{"child":"b1_label","variant":"primary","action":{"name":"click"}}}}"#,
//            #"{"id":"b2_label","component":{"Text":{"text":"Secondary"}}}"#,
//            #"{"id":"b2","component":{"Button":{"child":"b2_label","action":{"name":"click"}}}}"#
//        ]),
//        Section(name: "Inputs", components: [
//            #"{"id":"root","component":{"Card":{"child":"root_col"}}}"#,
//            #"{"id":"root_col","component":{"Column":{"children":{"explicitList":["i_h2","i_tf","i_cb","i_sl","i_cp","i_dt"]}}}}"#,
//            #"{"id":"i_h2","component":{"Text":{"text":"Inputs","variant":"h2"}}}"#,
//            #"{"id":"i_tf","component":{"TextField":{"label":"Text Field","value":{"path":"/form/textfield"}}}}"#,
//            #"{"id":"i_cb","component":{"CheckBox":{"label":"Check Box","value":true}}}"#,
//            #"{"id":"i_sl","component":{"Slider":{"label":"Slider","min":0,"max":100,"value":50}}}"#,
//            #"{"id":"i_cp","component":{"ChoicePicker":{"label":"Choice Picker","options":[{"label":"Option 1","value":"1"},{"label":"Option 2","value":"2"}],"value":{"path":"/form/choice"}}}}"#,
//            #"{"id":"i_dt","component":{"DateTimeInput":{"label":"Date Time","value":"2024-02-23T12:00:00Z","enableDate":true}}}"#
//        ]),
//        Section(name: "Media", components: [
//            #"{"id":"root","component":{"Card":{"child":"root_col"}}}"#,
//            #"{"id":"root_col","component":{"Column":{"children":{"explicitList":["m_h2","m_img","m_icon"]}}}}"#,
//            #"{"id":"m_h2","component":{"Text":{"text":"Media","variant":"h2"}}}"#,
//            #"{"id":"m_img","component":{"Image":{"url":"https://picsum.photos/400/200"}}}"#,
//            #"{"id":"m_icon","component":{"Icon":{"name":"star"}}}"#
//        ]),
	]
}
