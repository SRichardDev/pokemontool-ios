
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
    static let subscribedGeohashPokestops = "subscribedGeohashPokestops"
    static let subscribedGeohashArenas = "subscribedGeohashArenas"
    static let pushActive = "isPushActive"
    
    static let testpokestops = "test_pokestops"
    static let testarenas = "test_arenas"
}

struct Topics {
    static let quests = "quests"
    static let raids = "raids"
    static let level = "level-"
}

protocol FirebaseDelegate: class {
    func didAddPokestop(pokestop: Pokestop)
    func didUpdatePokestop(pokestop: Pokestop)
    func didAddArena(arena: Arena)
    func didUpdateArena(arena: Arena)
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
