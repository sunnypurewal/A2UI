import Foundation
import A2UI

extension GalleryComponent {
    static let emailFunction: Self = {
        return .init(
            id: "email",
            template: #"{"id":"gallery_component","checks":[{"condition":{"call":"email","args":{"value":{"path":"/email"}}},"message":"Invalid email format"}],"component":{"TextField":{"value":{"path":"/email"},"label":"Email Validation Demo"}}}"#,
            staticComponents: [.root],
            dataModelFields: [
                DataModelField(path: "/email", label: "Email", value: .string("test@example.com"), showInEditor: false)
            ],
            properties: []
        )
    }()
}
