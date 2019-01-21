
import Foundation

struct Pokestop {
    let name: String
    let latitude: Double
    let longitude: Double
    let id: String?
    let quest: Quest?
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

