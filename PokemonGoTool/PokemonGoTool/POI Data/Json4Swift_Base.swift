
import Foundation
struct Json4Swift_Base: Codable {
	let s2l20: String
	let name: String
	let id: String
	let portal: Bool?
	let gym: Bool
	let stop: Bool
	let ts: Int
	let loc: Loc

	enum CodingKeys: String, CodingKey {
		case s2l20 = "s2l20"
		case name = "name"
		case id = "id"
		case portal = "portal"
		case gym = "gym"
		case stop = "stop"
		case ts = "ts"
		case loc = "loc"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		s2l20 = try values.decode(String.self, forKey: .s2l20)
		name = try values.decode(String.self, forKey: .name)
		id = try values.decode(String.self, forKey: .id)
		portal = try values.decodeIfPresent(Bool.self, forKey: .portal)
		gym = try values.decode(Bool.self, forKey: .gym)
		stop = try values.decode(Bool.self, forKey: .stop)
		ts = try values.decode(Int.self, forKey: .ts)
		loc = try values.decode(Loc.self, forKey: .loc)
	}
}
