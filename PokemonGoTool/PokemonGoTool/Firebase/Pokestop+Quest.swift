
import Foundation
import Firebase
import CodableFirebase

protocol FirebaseCodable: Codable {
    var id: String! {get set}
    mutating func setId(_ documentId: String)
}

extension FirebaseCodable {
    mutating func setId(_ id: String) {}
}

struct Pokestop: FirebaseCodable {
    let name: String
    let latitude: Double
    let longitude: Double
    let submitter: String
    var id: String!
    let quest: Quest?
    let upVotes: Int?
    let downVotes: Int?
    var geohash: String {
        get {
            return Geohash.encode(latitude: latitude, longitude: longitude)
        }
    }
    
    mutating func setId(_ id: String) {
        self.id = id
    }
}

func decode<T: FirebaseCodable>(from snapshot: DataSnapshot) -> T? {
    if let data = snapshot.value {
        do {
            var object = try FirebaseDecoder().decode(T.self, from: data)
            object.setId(snapshot.key)
            return object
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    return nil
}

struct Quest: Codable {
    let name: String
    let reward: String
    let submitter: String
}

struct Arena: Codable {
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

struct Raid: Codable {
    let level: Int
    let hatchTime: String
    let participants: [User]
}

