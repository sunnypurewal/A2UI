import Foundation
import A2UI

extension GalleryComponent {
    static let lengthFunction: Self = {
        return .init(
            id: "length",
            template: #"{"id":"gallery_component","checks":[{"condition":{"call":"length","args":{"value":{"path":"/username"},"min":3,"max":10}},"message":"Username must be between 3 and 10 characters"}],"component":{"TextField":{"value":{"path":"/username"},"label":"Length Demo (3-10 characters)"}}}"#,
            staticComponents: [.validationRoot, .validationPreview],
            dataModelFields: [
                DataModelField(path: "/username", label: "Username", value: .string("abc"), showInEditor: false)
            ],
            properties: []
        )
    }()
}
