
import Foundation

struct DatabaseKeys {
    static let pokestops = "pokestops"
    static let arenas = "arenas"
    static let registeredUsersPokestops = "registeredUsersPokestops"
    static let registeredUsersArenas = "registeredUsersArenas"
    static let raidMeetups = "raidMeetups"
    static let users = "users"
    static let quest = "quest"
    static let raid = "raid"
    static let raidMeetupId = "raidMeetupId"
    static let raidBossId = "raidBossId"
    static let quests = "quests"
    static let raidBosses = "raidBosses"
    static let timestamp = "timestamp"
    static let registeredUser = "registeredUsers"
    static let participants = "participants"
    static let chat = "chat"
    static let trainerName = "trainerName"
    static let goldArenas = "goldArenas"
    static let submittedQuests = "submittedQuests"
    static let submittedRaids = "submittedRaids"
    static let submittedArenas = "submittedArenas"
    static let submittedPokestops = "submittedPokestops"
    static let publicUserData = "publicData"
    static let team = "team"
    static let level = "level"
    static let trainerCode = "trainerCode"
    
    @available(*, deprecated, message: "Old - remove soon")
    static let subscribedGeohashPokestops = "subscribedGeohashPokestops"
    @available(*, deprecated, message: "Old - remove soon")
    static let subscribedGeohashArenas = "subscribedGeohashArenas"
    
    static let pushActive = "isPushActive"
    static let topics = "topics"
    static let subscribedGeohashes = "subscribedGeohashes"
    static let notificationToken = "notificationToken"
    static let platform = "platform"
    static let appLastOpened = "appLastOpened"
    static let subscribedRaidMeetups = "subscribedRaidMeetups"
    
    static let testpokestops = "test_pokestops"
    static let testarenas = "test_arenas"
}

struct Topics {
    static let quests = "quests"
    static let raids = "raids"
    static let incidents = "incidents"
    static let level = "level-"
    static let iOS = "iOS"
}

protocol FirebaseUserDelegate: class {
    func didUpdateUser()
}

protocol FirebaseStartupDelegate: class {
    func didLoadInitialData()
}

protocol FirebaseStatusPresentable: class {
}

protocol RaidMeetupDelegate: class {
    func didUpdateRaidMeetup(_ changedRaidMeetup: RaidMeetup)
}

protocol RaidChatDelegate: class {
    func didReceiveNewChatMessage(_ message: ChatMessage)
}

enum AuthStatus {
    case signedUp
    case signedIn
    case signedOut
    case weakPassword
    case invalidCredential
    case emailAlreadyInUse
    case invalidEmail
    case networkError
    case missingEmail
    case unknown(error: String)
}

@available(*, deprecated, message: "Old method - delete soon")
enum PoiType {
    case pokestop
    case arena
    
    var databaseKey: String {
        get {
            switch self {
            case .pokestop:
                return DatabaseKeys.subscribedGeohashPokestops
            case .arena:
                return DatabaseKeys.subscribedGeohashArenas
            }
        }
    }
}
