import Foundation

public struct ComponentInstance: Codable {
    public let id: String
    public let weight: Double?
    public let checks: [CheckRule]?
    public let component: ComponentType
    
    public init(id: String, weight: Double? = nil, checks: [CheckRule]? = nil, component: ComponentType) {
        self.id = id
        self.weight = weight
        self.checks = checks
        self.component = component
    }

    enum CodingKeys: String, CodingKey {
        case id, weight, checks, component
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.weight = try container.decodeIfPresent(Double.self, forKey: .weight)
        self.checks = try container.decodeIfPresent([CheckRule].self, forKey: .checks)

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

extension ComponentInstance {
    public var componentTypeName: String {
        component.typeName
    }
}
