import Foundation

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
