
import Foundation
import UIKit

struct Pokestop: Annotation, FirebaseCodable, Equatable, Hashable {
    var name: String
    var latitude: Double
    var longitude: Double
    var submitter: String
    var id: String!
    var questId: String?
    var quest: Quest?
    var incident: Incident?
    var lureId: Lure?
    var upVotes: Int?
    var downVotes: Int?
    var geohash: String {
        get {
            return Geohash.encode(latitude: latitude, longitude: longitude)
        }
    }
    
    var image: UIImage {
        get {
            return UIImage(named: "PokestopLarge")!
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

struct Lure: Codable, Equatable {
    var id: LureType
    var expiration: Date
    var submitter: String
    
    var isActive: Bool {
        return expiration > Date()
    }
}

struct LureType: Codable, Equatable, RawRepresentable {
    let rawValue: Int
    
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    init(_ rawValue: Int) {
        self.rawValue = rawValue
    }
    
    static let normal = LureType(501)
    static let glacier = LureType(502)
    static let mossy = LureType(503)
    static let magnetic = LureType(504)
}

struct Incident: Codable, Equatable {
    var start: Date
    var expiration: Date
    var gruntType: GruntType
    var submitter: String
    
    var isActive: Bool {
        return expiration > Date()
    }
    
    var descripiton: String {
        switch gruntType {
        case .random4, .random5:
            return "Zufällig"
        case .bug6, .bug7:
            return "Käfer"
        case .ghost8, .ghost9:
            return "Geist"
        case .dark10, .dark11:
            return "Unlicht"
        case .dragon12, .dragon13:
            return "Drache"
        case .fairy14, .fairy15:
            return "Fee"
        case .fighting16, .fighting17:
            return "Kampf"
        case .fire18, .fire19:
            return "Feuer"
        case .flying20, .flying21:
            return "Flug"
        case .grass22, .grass23:
            return "Pflanze"
        case .ground24, .ground25:
            return "Boden"
        case .ice26, .ice27:
            return "Eis"
        case .metal28, .metal29:
            return "Metall"
        case .normal30, .normal31:
            return "Normal"
        case .poison32, .poison33:
            return "Gift"
        case .psychic34, .psychic35:
            return "Psycho"
        case .rock36, .rock37:
            return "Gestein"
        case .water38, .water39:
            return "Wasser"
        default:
            return "Unbekannt"
        }
    }
}

struct GruntType: Codable, Equatable, RawRepresentable {
    let rawValue: Int
    
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    init(_ rawValue: Int) {
        self.rawValue = rawValue
    }
    
    static let random4 = GruntType(4)
    static let random5 = GruntType(5)
    static let bug6 = GruntType(6)
    static let bug7 = GruntType(7)
    static let ghost8 = GruntType(8)
    static let ghost9 = GruntType(9)
    static let dark10 = GruntType(10)
    static let dark11 = GruntType(11)
    static let dragon12 = GruntType(12)
    static let dragon13 = GruntType(13)
    static let fairy14 = GruntType(14)
    static let fairy15 = GruntType(15)
    static let fighting16 = GruntType(16)
    static let fighting17 = GruntType(17)
    static let fire18 = GruntType(18)
    static let fire19 = GruntType(19)
    static let flying20 = GruntType(20)
    static let flying21 = GruntType(21)
    static let grass22 = GruntType(22)
    static let grass23 = GruntType(23)
    static let ground24 = GruntType(24)
    static let ground25 = GruntType(25)
    static let ice26 = GruntType(26)
    static let ice27 = GruntType(27)
    static let metal28 = GruntType(28)
    static let metal29 = GruntType(29)
    static let normal30 = GruntType(30)
    static let normal31 = GruntType(31)
    static let poison32 = GruntType(32)
    static let poison33 = GruntType(33)
    static let psychic34 = GruntType(34)
    static let psychic35 = GruntType(35)
    static let rock36 = GruntType(36)
    static let rock37 = GruntType(37)
    static let water38 = GruntType(38)
    static let water39 = GruntType(39)
}

struct Quest: Codable, Equatable {
    let definitionId: String
    let submitter: String
    var timestamp: TimeInterval?
    
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
