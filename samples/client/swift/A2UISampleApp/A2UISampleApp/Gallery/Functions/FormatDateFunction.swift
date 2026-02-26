import Foundation
import A2UI

extension GalleryComponent {
    static let formatDateFunction: Self = {
        return .init(
            id: "formatDate",
            template: #"{"id":"gallery_component","component":{"Column":{"children":["t_body"],"justify":"center","align":"center"}}}"#,
            staticComponents: [.root, .formatDateText],
            dataModelFields: [
                DataModelField(path: "/date", label: "ISO Date", value: .string("2026-02-26T14:30:00Z"), showInEditor: false)
            ],
            properties: [
                PropertyDefinition(key: "dateFormat", label: "Format", options: ["MMM dd, yyyy", "HH:mm", "h:mm a", "EEEE, d MMMM"], value: "MMM dd, yyyy")
            ]
        )
    }()
}
