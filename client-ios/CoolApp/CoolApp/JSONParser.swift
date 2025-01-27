import Foundation

extension String: Error {}

class JSONParser {
    func parse(json: Data) throws -> [Component] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
//            throw "Jesus Christ"
            let topLevel = try decoder.decode(TopLevel.self, from: json)
            print("JSON parsed successfully0: \(topLevel.screen.components)")
            return topLevel.screen.components
        } catch {
            print("Failed to parse JSON: \(error)")
            throw error
        }
    }
}
