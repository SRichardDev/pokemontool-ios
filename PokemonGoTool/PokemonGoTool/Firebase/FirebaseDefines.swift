
import Foundation

struct DatabaseKeys {
    static let pokestops = "pokestops"
    static let arenas = "arenas"
    static let raidMeetups = "raidMeetups"
    static let users = "users"
    static let quest = "quest"
    static let raid = "raid"
    static let raidMeetupId = "raidMeetupId"
    static let quests = "quests"
    static let raidBosses = "raidBosses"
    static let timestamp = "timestamp"
    static let registeredUser = "registered_user"
    static let participants = "participants"
    static let chat = "chat"
    static let trainerName = "trainerName"
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
    func didUpdateRaidMeetup(_ raidMeetup: RaidMeetup)
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
