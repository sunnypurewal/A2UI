import Foundation
import A2UI

extension GalleryComponent {
    static let emailFunction: Self = {
        return .init(
            id: "email",
            template: #"{"id":"gallery_component","checks":[{"condition":{"call":"email","args":{"value":{"path":"/email"}}},"message":"Invalid email format"}],"component":{"TextField":{"value":{"path":"/email"},"label":"Email Validation Demo"}}}"#,
            staticComponents: [.root],
            dataModelFields: [
                DataModelField(path: "/email", label: "Email", value: .string("test@example.com"))
            ],
            properties: []
        )
    }()

    static let requiredFunction: Self = {
        return .init(
            id: "required",
            template: #"{"id":"gallery_component","checks":[{"condition":{"call":"required","args":{"value":{"path":"/name"}}},"message":"Name is required"}],"component":{"TextField":{"value":{"path":"/name"},"label":"Required Demo"}}}"#,
            staticComponents: [.root],
            dataModelFields: [
                DataModelField(path: "/name", label: "Name", value: .string(""))
            ],
            properties: []
        )
    }()

    static let lengthFunction: Self = {
        return .init(
            id: "length",
            template: #"{"id":"gallery_component","checks":[{"condition":{"call":"length","args":{"value":{"path":"/username"},"min":3,"max":10}},"message":"Username must be between 3 and 10 characters"}],"component":{"TextField":{"value":{"path":"/username"},"label":"Length Demo (3-10 characters)"}}}"#,
            staticComponents: [.root],
            dataModelFields: [
                DataModelField(path: "/username", label: "Username", value: .string("abc"))
            ],
            properties: []
        )
    }()

    static let regexFunction: Self = {
        return .init(
            id: "regex",
            template: #"{"id":"gallery_component","checks":[{"condition":{"call":"regex","args":{"value":{"path":"/code"},"pattern":"^[A-Z]{3}-[0-9]{3}$"}},"message":"Format must be AAA-000"}],"component":{"TextField":{"value":{"path":"/code"},"label":"Regex Demo (AAA-000)"}}}"#,
            staticComponents: [.root],
            dataModelFields: [
                DataModelField(path: "/code", label: "Code", value: .string("ABC-123"))
            ],
            properties: []
        )
    }()

    static let numericFunction: Self = {
        return .init(
            id: "numeric",
            template: #"{"id":"gallery_component","checks":[{"condition":{"call":"numeric","args":{"value":{"path":"/age"},"min":18,"max":99}},"message":"Age must be between 18 and 99"}],"component":{"Slider":{"value":{"path":"/age"},"label":"Numeric Demo (18-99)","min":0,"max":120}}}"#,
            staticComponents: [.root],
            dataModelFields: [
                DataModelField(path: "/age", label: "Age", value: .number(25))
            ],
            properties: []
        )
    }()

    static let formatDateFunction: Self = {
        return .init(
            id: "formatDate",
            template: #"{"id":"gallery_component","component":{"Column":{"children":["t_body"],"justify":"center","align":"center"}}}"#,
            staticComponents: [.root, .formatDateText],
            dataModelFields: [
                DataModelField(path: "/date", label: "ISO Date", value: .string("2026-02-26T14:30:00Z"))
            ],
            properties: [
                PropertyDefinition(key: "dateFormat", label: "Format", options: ["MMM dd, yyyy", "HH:mm", "h:mm a", "EEEE, d MMMM"], value: "MMM dd, yyyy")
            ]
        )
    }()

    static let formatCurrencyFunction: Self = {
        return .init(
            id: "formatCurrency",
            template: #"{"id":"gallery_component","component":{"Column":{"children":["t_body"],"justify":"center","align":"center"}}}"#,
            staticComponents: [.root, .formatCurrencyText],
            dataModelFields: [
                DataModelField(path: "/amount", label: "Amount", value: .number(1234.56))
            ],
            properties: [
                PropertyDefinition(key: "currencyCode", label: "Currency", options: ["USD", "EUR", "GBP", "JPY"], value: "USD")
            ]
        )
    }()

    static let pluralizeFunction: Self = {
        return .init(
            id: "pluralize",
            template: #"{"id":"gallery_component","component":{"Column":{"children":["gallery_input","t_body"],"justify":"center","align":"center"}}}"#,
            staticComponents: [.root, .pluralizeText, .pluralizeInput],
            dataModelFields: [
                DataModelField(path: "/count", label: "Count", value: .number(1))
            ],
            properties: []
        )
    }()
}
