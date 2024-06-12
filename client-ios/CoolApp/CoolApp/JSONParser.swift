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
        children = try container.decodeIfPresent([Component].self, forKey: .children)
        properties = try container.decode([String: AnyDecodable].self, forKey: .properties).mapValues { $0.value }
    }
}

struct AnyDecodable: Decodable {
    let value: Any

    init(from decoder: Decoder) throws {
        if let intValue = try? decoder.singleValueContainer().decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? decoder.singleValueContainer().decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? decoder.singleValueContainer().decode(String.self) {
            value = stringValue
        } else if let boolValue = try? decoder.singleValueContainer().decode(Bool.self) {
            value = boolValue
        } else if let nestedDictionary = try? decoder.singleValueContainer().decode([String: AnyDecodable].self) {
            value = nestedDictionary.mapValues { $0.value }
        } else if let nestedArray = try? decoder.singleValueContainer().decode([AnyDecodable].self) {
            value = nestedArray.map { $0.value }
        } else {
            throw DecodingError.typeMismatch(AnyDecodable.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Type not supported"))
        }
    }
}

class JSONParser {
    func parse(json: Data) throws -> Component {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let component = try decoder.decode(Component.self, from: json)
                    print("JSON parsed successfully: \(component)")
                    return component
                } catch {
                    print("Failed to parse JSON: \(error)")
                    throw error
                }
    }
}
