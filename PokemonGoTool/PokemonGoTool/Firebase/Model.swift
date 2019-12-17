
import Foundation
import Firebase
import CodableFirebase
import MapKit

protocol FirebaseCodable: Codable {
    var id: String! {get set}
    mutating func setId(_ documentId: String)
}

extension FirebaseCodable {
    mutating func setId(_ id: String) {
        self.id = id
    }
}

func decode<T: FirebaseCodable>(from snapshot: DataSnapshot) -> T? {
    if let data = snapshot.value {
        do {
            let decoder = FirebaseDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            var object = try decoder.decode(T.self, from: data)
            object.setId(snapshot.key)
            return object
        } catch _ {
            //Error for registred push users
            //            print("Error decoding: \(error.localizedDescription) : \(T.self)")
        }
    }
    return nil
}

protocol Annotation  {
    var name: String { get set }
    var latitude: Double { get set }
    var longitude: Double { get set }
    var upVotes: Int? { get set }
    var downVotes: Int? { get set }
    var id: String! { get set }
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
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
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

struct Raid: FirebaseCodable, Equatable {
    
    var id: String!
    
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
        guard let hatchTime = hatchTime else { return nil }
        return Date(timeIntervalSince1970: hatchTime/1000)
    }
    
    var endDate: Date? {
        guard let endTime = endTime else { return nil }
        return Date(timeIntervalSince1970: endTime/1000)
    }
    
    var image: UIImage? {
            return nil
        #warning("TODO")
//            let raidboss = RaidbossManager.shared.raidboss(for: raidBossId)
//            let raidbossImage = ImageManager.image(named: "\(raidboss?.imageName ?? "")")
//            let eggImage = ImageManager.image(named: "level_\(level)")
//            let eggHatchedImage = ImageManager.image(named: "level_\(level)_hatched")
//
//            return hasHatched ? (raidbossImage ?? eggHatchedImage) : eggImage
    }
    
    var timestamp: TimeInterval?
    let level: Int
    var hatchTime: TimeInterval?
    var endTime: TimeInterval?
    var raidBossId: String?
    var meetup: RaidMeetup?
    var submitter: String?
    var submitDate: Date? {
        return timestamp?.dateFromUnixTime()
    }
    
    init(level: Int,
         hatchDate: Date? = nil,
         endDate: Date? = nil,
         submitter: String,
         raidBoss: String? = nil,
         meetup: RaidMeetup) {
        
        self.level = level
        self.hatchTime = hatchDate?.timestamp ?? 0
        self.endTime = endDate?.timestamp ?? 0
        self.submitter = submitter
        self.raidBossId = raidBoss
        self.meetup = meetup
    }
}

struct RaidMeetup: Codable, Equatable {
    
    typealias UserId = String
    
    var meetupTime: TimeInterval
    var participants: [UserId: String]?
    var chatId: String?
    
    var meetupDate: Date? {
        get {
            return meetupTime == 0 ? nil : Date(timeIntervalSince1970: meetupTime/1000)
        }
    }
    
    var isTimeSet: Bool {
        return meetupTime != 0
    }
    
    init(meetupDate: Date? = nil) {
        self.meetupTime = meetupDate?.timestamp ?? 0
    }
}

struct ChatMessage: FirebaseCodable {
    var id: String!
    let message: String
    let senderId: String
    var timestamp: TimeInterval?

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
