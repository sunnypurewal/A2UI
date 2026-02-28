import Foundation
import A2UI

extension GalleryComponent {
    static let formatDateFunction: Self = {
        return .init(
            id: "formatDate",
            template: #"{"id":"gallery_component","component":{"Column":{"children":["t_body"],"justify":"center","align":"center"}}}"#,
            staticComponents: [.root, .formatDateText],
            dataModelFields: [
				DataModelField(path: "/date", label: "ISO Date", value: .string(Date.now.ISO8601Format()), showInEditor: false),
				DataModelField(path: "/dateFormat", label: "Date Format", value: .string("MMM d, yyyy"))
            ],
            properties: []
        )
    }()
}
