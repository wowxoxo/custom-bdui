import Foundation

struct Screen: Decodable {
    let id: String
    let components: [Component]
    
    enum CodingKeys: String, CodingKey {
        case id, components
    }
}
