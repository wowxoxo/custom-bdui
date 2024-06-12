import Foundation

struct Component: Decodable {
    let type: String
    let properties: [String: Any]
    let children: [Component]?
    
    enum CodingKeys: String, CodingKey {
        case type, properties, children
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        print("Decoded type: \(type)")
        children = try container.decodeIfPresent([Component].self, forKey: .children)
        
        let propertiesContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .properties)
        properties = try Component.decodeProperties(container: propertiesContainer)
        print("Decoded properties: \(properties)")
    }
    
    private static func decodeProperties(container: KeyedDecodingContainer<CodingKeys>) throws -> [String: Any] {
        var properties: [String: Any] = [:]
        
        for key in container.allKeys {
            if let value = try? container.decode(AnyDecodable.self, forKey: key) {
                properties[key.stringValue] = value.value
            }
        }
        print("Decoded properties: \(properties)")
        return properties
    }
}
