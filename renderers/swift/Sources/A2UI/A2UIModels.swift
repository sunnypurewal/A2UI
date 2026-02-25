import Foundation

/// The root message received from the A2UI stream.
/// Each line in the JSONL stream should decode into this enum.
/// Strictly supports A2UI v0.10 specification.
public enum A2UIMessage: Codable {
    case createSurface(CreateSurfaceMessage)
    case surfaceUpdate(SurfaceUpdate)
    case dataModelUpdate(DataModelUpdate)
    case deleteSurface(DeleteSurface)
    case appMessage(name: String, data: [String: AnyCodable])

    enum CodingKeys: String, CodingKey {
        case version
        case createSurface
        case updateComponents
        case updateDataModel
        case deleteSurface
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Strictly validate version if present
        if let version = try? container.decode(String.self, forKey: .version), version != "v0.10" {
            throw DecodingError.dataCorruptedError(forKey: .version, in: container, debugDescription: "Unsupported A2UI version: \(version). Only v0.10 is supported.")
        }
        
        if container.contains(.createSurface) {
            self = .createSurface(try container.decode(CreateSurfaceMessage.self, forKey: .createSurface))
        } else if container.contains(.updateComponents) {
            self = .surfaceUpdate(try container.decode(SurfaceUpdate.self, forKey: .updateComponents))
        } else if container.contains(.updateDataModel) {
            self = .dataModelUpdate(try container.decode(DataModelUpdate.self, forKey: .updateDataModel))
        } else if container.contains(.deleteSurface) {
            self = .deleteSurface(try container.decode(DeleteSurface.self, forKey: .deleteSurface))
        } else {
            // App Message handling: catch any other top-level key that isn't an A2UI core message
            let anyContainer = try decoder.container(keyedBy: AnyCodingKey.self)
            let knownKeys = Set(CodingKeys.allCases.map { $0.stringValue })
            let unknownKeys = anyContainer.allKeys.filter { !knownKeys.contains($0.stringValue) && $0.stringValue != "version" }
            
            if let key = unknownKeys.first {
                let dataValue = try anyContainer.decode(AnyCodable.self, forKey: key)
                self = .appMessage(name: key.stringValue, data: [key.stringValue: dataValue])
            } else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Missing or unknown A2UI v0.10 Message")
                )
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("v0.10", forKey: .version)
        switch self {
        case .createSurface(let value):
            try container.encode(value, forKey: .createSurface)
        case .surfaceUpdate(let value):
            try container.encode(value, forKey: .updateComponents)
        case .dataModelUpdate(let update):
            try container.encode(update, forKey: .updateDataModel)
        case .deleteSurface(let value):
            try container.encode(value, forKey: .deleteSurface)
        case .appMessage(let name, let data):
            var anyContainer = encoder.container(keyedBy: AnyCodingKey.self)
            if let key = AnyCodingKey(stringValue: name), let val = data[name] {
                try anyContainer.encode(val, forKey: key)
            }
        }
    }
}

struct AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    init?(stringValue: String) { self.stringValue = stringValue; self.intValue = nil }
    init?(intValue: Int) { self.stringValue = String(intValue); self.intValue = intValue }
}

extension A2UIMessage.CodingKeys: CaseIterable {}

// MARK: - Message Types

public struct CreateSurfaceMessage: Codable {
    public let surfaceId: String
    public let catalogId: String
    public let theme: [String: AnyCodable]?
    public let sendDataModel: Bool?

    enum CodingKeys: String, CodingKey {
        case surfaceId, catalogId, theme, sendDataModel
    }
}

public struct SurfaceUpdate: Codable {
    public let surfaceId: String
    public let components: [ComponentInstance]
    
    enum CodingKeys: String, CodingKey {
        case surfaceId, components
    }
}

public struct DataModelUpdate: Codable {
    public let surfaceId: String
    public let path: String?
    public let value: AnyCodable?

    enum CodingKeys: String, CodingKey {
        case surfaceId, path, value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        surfaceId = try container.decode(String.self, forKey: .surfaceId)
        path = try container.decodeIfPresent(String.self, forKey: .path)
        value = try container.decodeIfPresent(AnyCodable.self, forKey: .value)
    }
}

public struct DeleteSurface: Codable {
    public let surfaceId: String
}

public struct UserAction: Codable {
    public let surfaceId: String
    public let action: Action
}

// MARK: - Component Structure

public struct ComponentInstance: Codable {
    public let id: String
    public let weight: Double?
    public let component: ComponentType
    
    public init(id: String, weight: Double? = nil, component: ComponentType) {
        self.id = id
        self.weight = weight
        self.component = component
    }

    enum CodingKeys: String, CodingKey {
        case id, weight, component
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.weight = try container.decodeIfPresent(Double.self, forKey: .weight)

        // Try two formats:
        // Format 1: component is a string (type name) with properties at same level
        if let typeName = try? container.decode(String.self, forKey: .component) {
            self.component = try ComponentType(typeName: typeName, from: decoder)
        } else {
            // Format 2: component is an object like {"Text": {...}}
            self.component = try container.decode(ComponentType.self, forKey: .component)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(weight, forKey: .weight)
        try container.encode(component, forKey: .component)
    }
}

public enum ComponentType: Codable {
    public init(typeName: String, from decoder: Decoder) throws {
        switch typeName {
        case "Text": self = .text(try TextProperties(from: decoder))
        case "Button": self = .button(try ButtonProperties(from: decoder))
        case "Row": self = .row(try ContainerProperties(from: decoder))
        case "Column": self = .column(try ContainerProperties(from: decoder))
        case "Card": self = .card(try CardProperties(from: decoder))
        case "Image": self = .image(try ImageProperties(from: decoder))
        case "Icon": self = .icon(try IconProperties(from: decoder))
        case "Video": self = .video(try VideoProperties(from: decoder))
        case "AudioPlayer": self = .audioPlayer(try AudioPlayerProperties(from: decoder))
        case "Divider": self = .divider(try DividerProperties(from: decoder))
        case "List": self = .list(try ListProperties(from: decoder))
        case "Tabs": self = .tabs(try TabsProperties(from: decoder))
        case "Modal": self = .modal(try ModalProperties(from: decoder))
        case "TextField": self = .textField(try TextFieldProperties(from: decoder))
        case "CheckBox": self = .checkBox(try CheckBoxProperties(from: decoder))
        case "ChoicePicker": self = .choicePicker(try ChoicePickerProperties(from: decoder))
        case "Slider": self = .slider(try SliderProperties(from: decoder))
        case "DateTimeInput": self = .dateTimeInput(try DateTimeInputProperties(from: decoder))
        default:
            let props = try [String: AnyCodable](from: decoder)
            self = .custom(typeName, props)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RawCodingKey.self)
        guard let key = container.allKeys.first else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Missing component type")
            )
        }

        let nestedDecoder = try container.superDecoder(forKey: key)
        self = try ComponentType(typeName: key.stringValue, from: nestedDecoder)
    }
    case text(TextProperties)
    case button(ButtonProperties)
    case row(ContainerProperties)
    case column(ContainerProperties)
    case card(CardProperties)
    case image(ImageProperties)
    case icon(IconProperties)
    case video(VideoProperties)
    case audioPlayer(AudioPlayerProperties)
    case divider(DividerProperties)
    case list(ListProperties)
    case tabs(TabsProperties)
    case modal(ModalProperties)
    case textField(TextFieldProperties)
    case checkBox(CheckBoxProperties)
    case choicePicker(ChoicePickerProperties)
    case slider(SliderProperties)
    case dateTimeInput(DateTimeInputProperties)
    case custom(String, [String: AnyCodable])

    enum CodingKeys: String, CodingKey {
        case text = "Text", button = "Button", row = "Row", column = "Column", card = "Card"
        case image = "Image", icon = "Icon", video = "Video", audioPlayer = "AudioPlayer"
        case divider = "Divider", list = "List", tabs = "Tabs", modal = "Modal"
        case textField = "TextField", checkBox = "CheckBox", choicePicker = "ChoicePicker"
        case slider = "Slider", dateTimeInput = "DateTimeInput"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let p): try container.encode(p, forKey: .text)
        case .button(let p): try container.encode(p, forKey: .button)
        case .row(let p): try container.encode(p, forKey: .row)
        case .column(let p): try container.encode(p, forKey: .column)
        case .card(let p): try container.encode(p, forKey: .card)
        case .image(let p): try container.encode(p, forKey: .image)
        case .icon(let p): try container.encode(p, forKey: .icon)
        case .video(let p): try container.encode(p, forKey: .video)
        case .audioPlayer(let p): try container.encode(p, forKey: .audioPlayer)
        case .divider(let p): try container.encode(p, forKey: .divider)
        case .list(let p): try container.encode(p, forKey: .list)
        case .tabs(let p): try container.encode(p, forKey: .tabs)
        case .modal(let p): try container.encode(p, forKey: .modal)
        case .textField(let p): try container.encode(p, forKey: .textField)
        case .checkBox(let p): try container.encode(p, forKey: .checkBox)
        case .choicePicker(let p): try container.encode(p, forKey: .choicePicker)
        case .slider(let p): try container.encode(p, forKey: .slider)
        case .dateTimeInput(let p): try container.encode(p, forKey: .dateTimeInput)
        case .custom(let name, let props):
            var c = encoder.container(keyedBy: RawCodingKey.self)
            try c.encode(props, forKey: RawCodingKey(stringValue: name)!)
        }
    }
    
    public var typeName: String {
        switch self {
        case .text: return "Text"
        case .button: return "Button"
        case .row: return "Row"
        case .column: return "Column"
        case .card: return "Card"
        case .image: return "Image"
        case .icon: return "Icon"
        case .video: return "Video"
        case .audioPlayer: return "AudioPlayer"
        case .divider: return "Divider"
        case .list: return "List"
        case .tabs: return "Tabs"
        case .modal: return "Modal"
        case .textField: return "TextField"
        case .checkBox: return "CheckBox"
        case .choicePicker: return "ChoicePicker"
        case .slider: return "Slider"
        case .dateTimeInput: return "DateTimeInput"
        case .custom(let name, _): return name
        }
    }
}

struct RawCodingKey: CodingKey {
    var stringValue: String
    init?(stringValue: String) { self.stringValue = stringValue }
    var intValue: Int?
    init?(intValue: Int) { return nil }
}

// MARK: - Property Types

public struct TextProperties: Codable, Sendable {
    public let text: BoundValue<String>
    public let variant: String? // h1, h2, h3, h4, h5, caption, body
    
    public init(text: BoundValue<String>, variant: String?) {
        self.text = text
        self.variant = variant
    }
    
    enum CodingKeys: String, CodingKey {
        case text, variant
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(BoundValue<String>.self, forKey: .text)
        self.variant = try container.decodeIfPresent(String.self, forKey: .variant)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(variant, forKey: .variant)
    }
}

public struct ButtonProperties: Codable, Sendable {
    public let child: String
    public let action: Action
    public let variant: String? // primary, borderless
}

public struct ImageProperties: Codable, Sendable {
    public let url: BoundValue<String>
    public let fit: String? // contain, cover, fill, none, scaleDown
    public let variant: String? // icon, avatar, smallFeature, mediumFeature, largeFeature, header
}

public struct IconProperties: Codable, Sendable {
    public let name: BoundValue<String> // v0.10: String or path object, we'll keep it simple for now
}

public struct VideoProperties: Codable, Sendable {
    public let url: BoundValue<String>
}

public struct AudioPlayerProperties: Codable, Sendable {
    public let url: BoundValue<String>
    public let description: BoundValue<String>?
}

public struct ListProperties: Codable, Sendable {
    public let children: Children
    public let direction: String? // vertical, horizontal
    public let align: String?
}

public struct TabsProperties: Codable, Sendable {
    public let tabs: [TabItem]
}

public struct TabItem: Codable, Sendable {
    public let title: BoundValue<String>
    public let child: String
}

public struct ModalProperties: Codable, Sendable {
    public let trigger: String
    public let content: String
}

public struct DividerProperties: Codable, Sendable {
    public let axis: String? // horizontal, vertical
}

public struct TextFieldProperties: Codable, Sendable {
    public let label: BoundValue<String>
    public let value: BoundValue<String>?
    public let variant: String? // longText, number, shortText, obscured
}

public struct CheckBoxProperties: Codable, Sendable {
    public let label: BoundValue<String>
    public let value: BoundValue<Bool>
}

public struct ChoicePickerProperties: Codable, Sendable {
    public let label: BoundValue<String>?
    public let options: [SelectionOption]
    public let variant: String? // multipleSelection, mutuallyExclusive
    public let value: BoundValue<[String]>
}

public struct SelectionOption: Codable, Sendable {
    public let label: BoundValue<String>
    public let value: String
}

public struct SliderProperties: Codable, Sendable {
    public let label: BoundValue<String>?
    public let min: Double
    public let max: Double
    public let value: BoundValue<Double>
}

public struct DateTimeInputProperties: Codable, Sendable {
    public let label: BoundValue<String>?
    public let value: BoundValue<String>
    public let enableDate: Bool?
    public let enableTime: Bool?
    public let min: BoundValue<String>?
    public let max: BoundValue<String>?
}

public struct ContainerProperties: Codable, Sendable {
    public let children: Children
    public let justify: String?
    public let align: String?
}

extension ContainerProperties {
    var resolvedAlign: String {
        align ?? "start"
    }

    var resolvedJustify: String {
        justify ?? "start"
    }
}

public struct CardProperties: Codable, Sendable {
    public let child: String
}

// MARK: - Supporting Types

public struct Children: Codable, Sendable {
    public let explicitList: [String]?
    public let template: Template?
    
    public init(explicitList: [String]? = nil, template: Template? = nil) {
        self.explicitList = explicitList
        self.template = template
    }

    public init(from decoder: Decoder) throws {
        if let list = try? [String](from: decoder) {
            self.explicitList = list
            self.template = nil
        } else {
            self.template = try Template(from: decoder)
            self.explicitList = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let list = explicitList {
            try list.encode(to: encoder)
        } else if let template = template {
            try template.encode(to: encoder)
        }
    }
}

public struct Template: Codable, Sendable {
    public let componentId: String
    public let dataBinding: String
    
    enum CodingKeys: String, CodingKey {
        case componentId
        case dataBinding = "path"
    }
}

public struct FunctionCall: Codable, Sendable {
    public let call: String
    public let args: [String: AnyCodable]
    public let returnType: String?

    enum CodingKeys: String, CodingKey {
        case call, args, returnType
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        call = try container.decode(String.self, forKey: .call)
        args = try container.decodeIfPresent([String: AnyCodable].self, forKey: .args) ?? [:]
        returnType = try container.decodeIfPresent(String.self, forKey: .returnType)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(call, forKey: .call)
        if !args.isEmpty {
            try container.encode(args, forKey: .args)
        }
        try container.encodeIfPresent(returnType, forKey: .returnType)
    }
}

public enum Action: Codable, Sendable {
    case custom(name: String, context: [String: AnyCodable]?)
    case dataUpdate(DataUpdateAction)
    case functionCall(FunctionCall)

    enum CodingKeys: String, CodingKey {
        case name, context, dataUpdate, functionCall, event
    }

    struct EventPayload: Decodable {
        let name: String
        let context: [String: AnyCodable]?
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let dataUpdate = try? container.decode(DataUpdateAction.self, forKey: .dataUpdate) {
            self = .dataUpdate(dataUpdate)
        } else if let functionCall = try? container.decode(FunctionCall.self, forKey: .functionCall) {
            self = .functionCall(functionCall)
        } else if let event = try? container.decode(EventPayload.self, forKey: .event) {
            self = .custom(name: event.name, context: event.context)
        } else if let name = try? container.decode(String.self, forKey: .name) {
            let context = try? container.decode([String: AnyCodable].self, forKey: .context)
            self = .custom(name: name, context: context)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .name, in: container, debugDescription: "Unknown Action type")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .custom(let name, let context):
            try container.encode(name, forKey: .name)
            try container.encodeIfPresent(context, forKey: .context)
        case .dataUpdate(let du): try container.encode(du, forKey: .dataUpdate)
        case .functionCall(let fc): try container.encode(fc, forKey: .functionCall)
        }
    }
}

public struct DataUpdateAction: Codable, Sendable {
    public let path: String
    public let contents: AnyCodable // Can be a value or expression
}

// MARK: - Binding

public struct BoundValue<T: Codable & Sendable>: Codable, Sendable {
    public let literal: T?
    public let path: String?

    enum CodingKeys: String, CodingKey {
        case path
    }

    public init(literal: T? = nil, path: String? = nil) {
        self.literal = literal
        self.path = path
    }

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(), let val = try? container.decode(T.self) {
            self.literal = val
            self.path = nil
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.path = try container.decodeIfPresent(String.self, forKey: .path)
            self.literal = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let path = path {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(path, forKey: .path)
        } else if let literal = literal {
            var container = encoder.singleValueContainer()
            try container.encode(literal)
        }
    }
}

// MARK: - AnyCodable Helper
public struct JSONNull: Codable, Sendable, Hashable {
    public init() {}
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() { throw DecodingError.typeMismatch(JSONNull.self, .init(codingPath: decoder.codingPath, debugDescription: "")) }
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer(); try container.encodeNil()
    }
}

public struct AnyCodable: Codable, Sendable {
    public let value: Sendable
    public init(_ value: Sendable) { self.value = value }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() { value = JSONNull() }
        else if let x = try? container.decode(String.self) { value = x }
        else if let x = try? container.decode(Bool.self) { value = x }
        else if let x = try? container.decode(Double.self) { value = x }
        else if let x = try? container.decode([String: AnyCodable].self) { value = x.mapValues { $0.value } }
        else if let x = try? container.decode([AnyCodable].self) { value = x.map { $0.value } }
        else { throw DecodingError.dataCorruptedError(in: container, debugDescription: "Wrong type") }
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if value is JSONNull { try container.encodeNil() }
        else if let x = value as? String { try container.encode(x) }
        else if let x = value as? Bool { try container.encode(x) }
        else if let x = value as? Double { try container.encode(x) }
        else if let x = value as? [String: Sendable] { try container.encode(x.mapValues { AnyCodable($0) }) }
        else if let x = value as? [Sendable] { try container.encode(x.map { AnyCodable($0) }) }
    }
}
