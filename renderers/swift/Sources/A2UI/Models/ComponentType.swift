import Foundation

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
