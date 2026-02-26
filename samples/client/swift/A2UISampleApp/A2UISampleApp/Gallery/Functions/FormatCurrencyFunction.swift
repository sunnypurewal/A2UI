import Foundation
import A2UI

extension GalleryComponent {
    static let formatCurrencyFunction: Self = {
        return .init(
            id: "formatCurrency",
            template: #"{"id":"gallery_component","component":{"Column":{"children":["t_body"],"justify":"center","align":"center"}}}"#,
            staticComponents: [.root, .formatCurrencyText],
            dataModelFields: [
                DataModelField(path: "/amount", label: "Amount", value: .number(1234.56), showInEditor: false)
            ],
            properties: [
                PropertyDefinition(key: "currencyCode", label: "Currency", options: ["USD", "EUR", "GBP", "JPY"], value: "USD")
            ]
        )
    }()
}
