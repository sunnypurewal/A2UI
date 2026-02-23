import Foundation

struct GalleryData {
    struct Section: Identifiable {
        let id = UUID()
        let name: String
        let topLevelComponents: [String]
        let childComponents: [String]

        private var components: [String] {
            topLevelComponents + childComponents
        }

        var a2ui: String {
            let createSurfaceLine = #"{"version":"v0.10","createSurface":{"surfaceId":"\#(id)","catalogId":"a2ui.org:standard_catalog"}}"#
            let rootComponent = #"{"id":"root","component":{"Card":{"child":"root_col"}}}"#
            let rootColumn = #"{"id":"root_col","component":{"Column":{"children":{"explicitList":[\#(topLevelComponents.map { c in "\"\((c.split(separator: ",")[0].split(separator:":")[1]).trimmingCharacters(in: .init(charactersIn: "\"")))\"" }.joined(separator: ",")) ]}}}}"#
            
            var allComponents = self.components
            allComponents.append(rootComponent)
            allComponents.append(rootColumn)
            
            let updateComponentsLine = #"{"version":"v0.10","updateComponents":{"surfaceId":"\#(id)","components":[\#(allComponents.joined(separator: ","))]}}"#
            return [createSurfaceLine, updateComponentsLine].joined(separator: "\n")
        }
        
        var prettyJson: String {
            let entries = components.map { "    \($0)" }.joined(separator: ",\n")
            return "[\n\(entries)\n]"
        }
    }

    static let sections: [Section] = [
        Section(name: "Typography", topLevelComponents: [
            #"{"id":"t_h2","component":{"Text":{"text":"Typography","variant":"h2"}}}"#,
            #"{"id":"t_body","component":{"Text":{"text":"This is a body text showing how standard text renders.","variant":"body"}}}"#,
            #"{"id":"t_caption","component":{"Text":{"text":"This is a caption text.","variant":"caption"}}}"#
        ], childComponents: []),
        Section(name: "Buttons", topLevelComponents: [
            #"{"id":"b_h2","component":{"Text":{"text":"Buttons","variant":"h2"}}}"#,
            #"{"id":"b_row","component":{"Row":{"children":{"explicitList":["b1","b2"]}}}}"#
        ], childComponents: [
            #"{"id":"b1_label","component":{"Text":{"text":"Primary"}}}"#,
            #"{"id":"b1","component":{"Button":{"child":"b1_label","variant":"primary","action":{"name":"click"}}}}"#,
            #"{"id":"b2_label","component":{"Text":{"text":"Secondary"}}}"#,
            #"{"id":"b2","component":{"Button":{"child":"b2_label","action":{"name":"click"}}}}"#
        ]),
        Section(name: "Inputs", topLevelComponents: [
            #"{"id":"i_h2","component":{"Text":{"text":"Inputs","variant":"h2"}}}"#,
            #"{"id":"i_tf","component":{"TextField":{"label":"Text Field","value":{"path":"/form/textfield"}}}}"#,
            #"{"id":"i_cb","component":{"CheckBox":{"label":"Check Box","value":true}}}"#,
            #"{"id":"i_sl","component":{"Slider":{"label":"Slider","min":0,"max":100,"value":50}}}"#,
            #"{"id":"i_cp","component":{"ChoicePicker":{"label":"Choice Picker","options":[{"label":"Option 1","value":"1"},{"label":"Option 2","value":"2"}],"value":{"path":"/form/choice"}}}}"#,
            #"{"id":"i_dt","component":{"DateTimeInput":{"label":"Date Time","value":"2024-02-23T12:00:00Z","enableDate":true}}}"#
        ], childComponents: []),
        Section(name: "Media", topLevelComponents: [
            #"{"id":"m_h2","component":{"Text":{"text":"Media","variant":"h2"}}}"#,
            #"{"id":"m_img","component":{"Image":{"url":"https://picsum.photos/400/200"}}}"#,
            #"{"id":"m_icon","component":{"Icon":{"name":"star"}}}"#
        ], childComponents: []),
        Section(name: "Layout", topLevelComponents: [
            #"{"id":"l_h2","component":{"Text":{"text":"Layout","variant":"h2"}}}"#,
            #"{"id":"l_div","component":{"Divider":{}}}"#,
            #"{"id":"l_tabs","component":{"Tabs":{"tabs":[{"title":"Tab 1","child":"t1_c"},{"title":"Tab 2","child":"t2_c"}]}}}"#
        ], childComponents: [
            #"{"id":"t1_c","component":{"Text":{"text":"Content for Tab 1"}}}"#,
            #"{"id":"t2_c","component":{"Text":{"text":"Content for Tab 2"}}}"#
        ])
    ]
}
