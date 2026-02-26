import Foundation
import A2UI

extension GalleryComponent {
    static let pluralizeFunction: Self = {
        return .init(
            id: "pluralize",
            template: #"{"id":"gallery_component","component":{"Column":{"children":["gallery_input","t_body"],"justify":"center","align":"center"}}}"#,
            staticComponents: [.root, .pluralizeText, .pluralizeInput],
            dataModelFields: [
                DataModelField(path: "/count", label: "Count", value: .number(1), showInEditor: false)
            ],
            properties: []
        )
    }()
}
