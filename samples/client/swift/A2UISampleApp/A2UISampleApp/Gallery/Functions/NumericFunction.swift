import Foundation
import A2UI

extension GalleryComponent {
    static let numericFunction: Self = {
        return .init(
            id: "numeric",
            template: #"{"id":"gallery_component","checks":[{"condition":{"call":"numeric","args":{"value":{"path":"/age"},"min":18,"max":99}},"message":"Age must be between 18 and 99"}],"component":{"Slider":{"value":{"path":"/age"},"label":"Numeric Demo (18-99)","min":0,"max":120}}}"#,
            staticComponents: [.root],
            dataModelFields: [
                DataModelField(path: "/age", label: "Age", value: .number(25), showInEditor: false)
            ],
            properties: []
        )
    }()
}
