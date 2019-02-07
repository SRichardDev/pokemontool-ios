
import Foundation
import Firebase
import CodableFirebase

protocol FirebaseCodable: Codable {
    var id: String? {get set}
    mutating func setId(_ documentId: String)
}

extension FirebaseCodable {
    mutating func setId(_ id: String) {
        self.id = id
    }
}

protocol Annotation  {
    var name: String { get set }
    var latitude: Double { get set }
    var longitude: Double { get set }
    var upVotes: Int? { get set }
    var downVotes: Int? { get set }
}

struct Pokestop: FirebaseCodable, Equatable, Annotation {
    var name: String
    var latitude: Double
    var longitude: Double
    var submitter: String
    var id: String?
    var quest: Quest?
    var upVotes: Int?
    var downVotes: Int?
    var geohash: String {
        get {
            return Geohash.encode(latitude: latitude, longitude: longitude)
        }
    }
    
    init(name: String, latitude: Double, longitude: Double, submitter: String) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.submitter = submitter
    }
    
    static func == (lhs: Pokestop, rhs: Pokestop) -> Bool {
        return lhs.name == rhs.name &&
            lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude &&
            lhs.submitter == rhs.submitter &&
            lhs.id == rhs.id
    }
    
    mutating func updateData(with pokestop: Pokestop) {
        name = pokestop.name
        latitude = pokestop.latitude
        longitude = pokestop.longitude
        submitter = pokestop.submitter
        id = pokestop.id
        quest = pokestop.quest
        upVotes = pokestop.upVotes
        downVotes = pokestop.downVotes
    }
}

func decode<T: FirebaseCodable>(from snapshot: DataSnapshot) -> T? {
    if let data = snapshot.value {
        do {
            var object = try FirebaseDecoder().decode(T.self, from: data)
            object.setId(snapshot.key)
            return object
        } catch _ {
            //Error for registred push users
//            print("Error decoding: \(error.localizedDescription) : \(T.self)")
        }
    }
    return nil
}

struct Quest: Codable {
    let name: String
    let reward: String
    let submitter: String
}

struct QuestDefinition: FirebaseCodable {
    var id: String?
    let quest: String
    let reward: String
}

struct Arena: FirebaseCodable, Annotation {    
    var name: String
    var latitude: Double
    var longitude: Double
    let submitter: String
    var isEX: Bool = false
    var id: String?
    var raid: Raid?
    var upVotes: Int?
    var downVotes: Int?
    var geohash: String {
        get {
            return Geohash.encode(latitude: latitude, longitude: longitude)
        }
    }
    
    init(name: String, latitude: Double, longitude: Double, submitter: String, isExArena: Bool) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.submitter = submitter
        self.isEX = isExArena
    }
}

struct Raid: Codable {
    let level: Int
    var hatchTime: String?
    var raidBoss: String?
    var timeLeft: String?
    var raidMeetup: RaidMeetup?
}

struct RaidMeetup: Codable {
    let meetupTime: String
    var participants: [User?]
}
