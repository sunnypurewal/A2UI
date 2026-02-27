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
            
            if !unknownKeys.isEmpty {
                var allData: [String: AnyCodable] = [:]
                for key in unknownKeys {
                    let dataValue = try anyContainer.decode(AnyCodable.self, forKey: key)
                    allData[key.stringValue] = dataValue
                }
                if unknownKeys.count > 1 {
                    A2UILogger.warning("A2UI message contains multiple unknown keys (\(unknownKeys.map { $0.stringValue }.joined(separator: ", "))). All keys will be included in the data dictionary, but only the first will be used as the message name.")
                }                let primaryName = unknownKeys.first!.stringValue
                self = .appMessage(name: primaryName, data: allData)
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
        case .appMessage(_, let data):
            var anyContainer = encoder.container(keyedBy: AnyCodingKey.self)
            for (keyStr, val) in data {
                if let key = AnyCodingKey(stringValue: keyStr) {
                    try anyContainer.encode(val, forKey: key)
                }
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
