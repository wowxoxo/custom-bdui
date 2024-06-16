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
        
        if let propertiesContainer = try? container.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: .properties) {
            properties = try Component.decodeProperties(container: propertiesContainer)
        } else {
            properties = [:]
        }
        print("Decoded properties: \(properties)")
    }
    
    private static func decodeProperties(container: KeyedDecodingContainer<DynamicCodingKeys>) throws -> [String: Any] {
        var properties: [String: Any] = [:]
        
        for key in container.allKeys {
            if let value = try? container.decode(String.self, forKey: key) {
                properties[key.stringValue] = value
            } else if let value = try? container.decode(Double.self, forKey: key) {
                properties[key.stringValue] = CGFloat(value)
            } else if let value = try? container.decode(Bool.self, forKey: key) {
                properties[key.stringValue] = value
            }
        }
        print("Decoded properties: \(properties)")
        return properties
    }
}

struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int?
    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
    }
}
