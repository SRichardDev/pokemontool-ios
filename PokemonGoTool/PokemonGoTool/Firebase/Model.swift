
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
    var questId: String?
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
            return quest?.isActive ?? false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(id)
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
    let submitter: String
    var timestamp: Double?
    
    var submitDate: Date? {
        get {
            return timestamp?.dateFromUnixTime()
        }
    }
    
    var isActive: Bool {
        get {
            guard let submitDate = submitDate else { return false }
            guard Calendar.current.isDate(submitDate, inSameDayAs: Date()) else { return false }
            return true
        }
    }
    
    init(definitionId: String, submitter: String) {
        self.definitionId = definitionId
        self.submitter = submitter
    }
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

struct RaidbossDefinition: FirebaseCodable, Equatable {
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(id)
    }
    
    var name: String
    var latitude: Double
    var longitude: Double
    let submitter: String
    var isEX: Bool
    var id: String!
    var raid: Raid?
    var upVotes: Int?
    var downVotes: Int?
    var isGoldArena: Bool?
    var geohash: String {
        get {
            return Geohash.encode(latitude: latitude, longitude: longitude)
        }
    }
    
    var hasActiveRaid: Bool {
        get {
            return raid?.isActive ?? false
        }
    }
    
    var image: UIImage {
        get {
            switch (isEX, isGoldArena) {
            case (true, true):
                return UIImage(named: "goldArenaEX")!
            case (true, false):
                return UIImage(named: "arenaEX")!
            case (false, true):
                return UIImage(named: "goldArena")!
            default:
                return UIImage(named: "arena")!
            }
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
    
    var isSubmittedBeforeHatchTime: Bool {
        get {
            return hatchTime != nil
        }
    }
    
    var isExpired: Bool {
        get {
            guard let submitDate = submitDate else { return true }
            guard Calendar.current.isDate(submitDate, inSameDayAs: Date()) else { return true }
            
            if let raidEndDate = endDate {
                return raidEndDate < Date()
            }

            if let hatchDate = hatchDate {
                return hatchDate < Date()
            }
            return true
        }
    }
    
    var isActive: Bool {
        get {
            return !isExpired
        }
    }
    
    var hasHatched: Bool {
        if let hatchDate = hatchDate {
            return hatchDate < Date()
        }
        return false
    }
    
    var hatchDate: Date? {
        get {
            if hatchTime == nil {
                guard let endDate = endDate else { return nil }
                let end = Calendar.current.date(byAdding: .minute, value: -45, to: endDate)
                return end
            }
            
            guard let hatchTime = hatchTime, let submitDate = submitDate else { return nil }
            guard Calendar.current.isDate(submitDate, inSameDayAs: Date()) else { return nil }
            let hatchDate = DateUtility.date(for: hatchTime)
            
            return hatchDate
        }
    }
    
    var endDate: Date? {
        get {
            guard let endTime = endTime else { return nil }
            let endDate = DateUtility.date(for: endTime)
            return endDate
        }
    }
    
    var image: UIImage? {
        get {
            let raidboss = RaidbossManager.shared.raidboss(for: raidBossId)
            let raidbossImage = ImageManager.image(named: "\(raidboss?.imageName ?? "")")
            let eggImage = ImageManager.image(named: "level_\(level)")
            let eggHatchedImage = ImageManager.image(named: "level_\(level)_hatched")
            
            return hasHatched ? (raidbossImage ?? eggHatchedImage) : eggImage
        }
    }
    
    var timestamp: Double?
    let level: Int
    var hatchTime: String?
    var raidBossId: String?
    var endTime: String?
    var raidMeetupId: String?
    var submitDate: Date? {
        get {
            return timestamp?.dateFromUnixTime()
        }
    }
    
    init(level: Int, hatchTime: String, endTime: String, raidBoss: String? = nil, raidMeetupId: String?) {
        self.level = level
        self.hatchTime = hatchTime
        self.raidBossId = raidBoss
        self.raidMeetupId = raidMeetupId
        self.endTime = endTime
    }
    
    init(level: Int, hatchTime: String, endTime: String, raidBoss: String? = nil) {
        self.level = level
        self.hatchTime = hatchTime
        self.raidBossId = raidBoss
        self.endTime = endTime
    }
    
    init(level: Int, raidBoss: String? = nil, endTime: String, raidMeetupId: String?) {
        self.level = level
        self.raidBossId = raidBoss
        self.endTime = endTime
        self.raidMeetupId = raidMeetupId
    }
    
    init(level: Int, raidBoss: String? = nil, endTime: String) {
        self.level = level
        self.raidBossId = raidBoss
        self.endTime = endTime
    }
}

struct RaidMeetup: FirebaseCodable, Equatable {
    
    typealias UserId = String
    
    var id: String!
    var meetupTime: String?
    var participants: [UserId: String]?
    
    init(meetupTime: String? = nil) {
        self.meetupTime = meetupTime
    }
}

struct ChatMessage: FirebaseCodable {
    var id: String!
    let message: String
    let senderId: String
    var timestamp: Double?

    init(message: String, senderId: String) {
        self.message = message
        self.senderId = senderId
    }
}

struct Participant {
    let id: String
    let level: Int
    var trainerCode: String?
    
    init(id: String, level: Int, trainerCode: String? = nil) {
        self.id = id
        self.level = level
        self.trainerCode = trainerCode
    }
}
