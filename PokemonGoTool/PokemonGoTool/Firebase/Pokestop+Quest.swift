
import Foundation
import Firebase
import CodableFirebase

protocol FirebaseCodable: Codable {
    var id: String! {get set}
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
    var id: String! { get set }
}

struct Pokestop: FirebaseCodable, Equatable, Annotation, Hashable {
    var name: String
    var latitude: Double
    var longitude: Double
    var submitter: String
    var id: String!
    var quest: Quest?
    var upVotes: Int?
    var downVotes: Int?
    var geohash: String {
        get {
            return Geohash.encode(latitude: latitude, longitude: longitude)
        }
    }
    
    var hasActiveQuest: Bool {
        get {
            return quest != nil
        }
    }
    
    var hashValue: Int {
        return name.hashValue ^ id.hashValue
    }
    
    init(name: String, latitude: Double, longitude: Double, submitter: String) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.submitter = submitter
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

struct Quest: Codable, Equatable {
    let definitionId: String
    let name: String
    let reward: String
    let submitter: String
}

struct QuestDefinition: FirebaseCodable {
    var id: String!
    let quest: String
    let reward: String
    let imageName: String
    
    var image: UIImage? {
        get {
            return ImageManager.image(named: imageName)
        }
    }
}

struct RaidbossDefinition: FirebaseCodable {
    var id: String!
    let name: String
    let level: String
    let imageName: String
    
    var image: UIImage? {
        get {
            return ImageManager.image(named: imageName)
        }
    }
}

struct Arena: FirebaseCodable, Annotation, Hashable {
    
    var hashValue: Int {
        return name.hashValue ^ id.hashValue
    }
    
    var name: String
    var latitude: Double
    var longitude: Double
    let submitter: String
    var isEX: Bool = false
    var id: String!
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

struct Raid: Codable, Equatable {
    var isActiveAndRunning: Bool {
        get {
            if let date = date {
                let timestampPlusTimeLeft = date.addingTimeInterval((timeLeft?.double ?? 0) * 60.0)
                return timestampPlusTimeLeft > Date()
            }
            return false
        }
    }
    
    var hasHatched: Bool {
        return timeLeft != nil
    }
    
    var timestamp: Double?
    let level: Int
    var hatchTime: String?
    var raidBoss: String
    var timeLeft: String?
    var raidMeetup: RaidMeetup?
    var date: Date? {
        get {
            return timestamp?.dateFromUnixTime()
        }
    }
    
    init(level: Int, hatchTime: String, raidBoss: String, raidMeetup: RaidMeetup) {
        self.level = level
        self.hatchTime = hatchTime
        self.raidBoss = raidBoss
        self.raidMeetup = raidMeetup
    }
    
    init(level: Int, hatchTime: String, raidBoss: String) {
        self.level = level
        self.hatchTime = hatchTime
        self.raidBoss = raidBoss
    }
    
    init(level: Int, raidBoss: String, timeLeft: String, raidMeetup: RaidMeetup) {
        self.level = level
        self.raidBoss = raidBoss
        self.timeLeft = timeLeft
        self.raidMeetup = raidMeetup
    }
    
    init(level: Int, raidBoss: String, timeLeft: String) {
        self.level = level
        self.raidBoss = raidBoss
        self.timeLeft = timeLeft
    }
}

struct RaidMeetup: Codable, Equatable {
    let meetupTime: String
    var participants: [User]
}
