
import Foundation

struct Pokestop {
    let name: String
    let latitude: Double
    let longitude: Double
    let submitter: String
    let id: String?
    let quest: Quest?
    let upVotes: Int?
    let downVotes: Int?
    var geohash: String {
        get {
            return Geohash.encode(latitude: latitude, longitude: longitude)
        }
    }
}

struct Quest {
    let name: String
    let reward: String
    let submitter: String
}

struct Arena {
    let name: String
    let latitude: Double
    let longitude: Double
    let submitter: String
    let id: String?
    let raid: Raid?
    let upVotes: Int?
    let downVotes: Int?
    var geohash: String {
        get {
            return Geohash.encode(latitude: latitude, longitude: longitude)
        }
    }
}

struct Raid {
    let level: Int
    let hatchTime: String
    let participants: [User]
}

