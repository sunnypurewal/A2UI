import Foundation
import A2UI

extension GalleryComponent {
    static let regexFunction: Self = {
        return .init(
            id: "regex",
            template: #"{"id":"gallery_component","checks":[{"condition":{"call":"regex","args":{"value":{"path":"/code"},"pattern":"^[A-Z]{3}-[0-9]{3}$"}},"message":"Format must be AAA-000"}],"component":{"TextField":{"value":{"path":"/code"},"label":"Regex Demo (AAA-000)"}}}"#,
            staticComponents: [.validationRoot, .validationPreview],
            dataModelFields: [
                DataModelField(path: "/code", label: "Code", value: .string("ABC-12"), showInEditor: false)
            ],
            properties: []
        )
    }()
}
