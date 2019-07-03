
import Foundation

struct Loc: Codable {
    
	let type: String
	let coordinates: [Double]

	enum CodingKeys: String, CodingKey {
		case type = "type"
		case coordinates = "coordinates"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		type = try values.decode(String.self, forKey: .type)
		coordinates = try values.decode([Double].self, forKey: .coordinates)
	}
}
