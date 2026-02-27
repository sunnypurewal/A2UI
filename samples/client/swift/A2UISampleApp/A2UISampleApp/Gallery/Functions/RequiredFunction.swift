import Foundation
import A2UI

extension GalleryComponent {
    static let requiredFunction: Self = {
        return .init(
            id: "required",
            template: #"{"id":"gallery_component","checks":[{"condition":{"call":"required","args":{"value":{"path":"/name"}}},"message":"Name is required"}],"component":{"TextField":{"value":{"path":"/name"},"label":"Required Demo"}}}"#,
            staticComponents: [.validationRoot, .validationPreview],
            dataModelFields: [
                DataModelField(path: "/name", label: "Name", value: .string(""), showInEditor: false)
            ],
            properties: []
        )
    }()
}
