
import Foundation
import Firebase
import FirebaseMessaging
import CodableFirebase
import NotificationBannerSwift

class FirebaseConnector {
    
    private var pokestopsRef = Database.database().reference(withPath: "test_pokestops")
    private var arenasRef = Database.database().reference(withPath: "arenas")
    private let raidMeetupsRef = Database.database().reference(withPath: "raidMeetups")
    private let usersRef = Database.database().reference(withPath: "users")
    
    private(set) var user: User? {
        didSet {
            userDelegate?.didUpdateUser()
        }
    }
    
    private var connectivityTimer: Timer?
    var pokestops: [String: Pokestop] = [:]
    var arenas: [String: Arena] = [:]
    var quests = [QuestDefinition]()
    var raidbosses = [RaidbossDefinition]()

    weak var delegate: FirebaseDelegate?
    weak var userDelegate: FirebaseUserDelegate?
    weak var startUpDelegate: FirebaseStartupDelegate?
    weak var raidMeetupDelegate: RaidMeetupDelegate?
    weak var raidChatDelegate: RaidChatDelegate?

    var isSignedIn: Bool {
        return Auth.auth().currentUser?.uid != nil ? true : false
    }
    
    init() {
        checkConnectivity()
        loadInitialData()
//        addRaidBosses()
//        addQuests()
//        addDummyPokestops()
    }
    
    private func loadInitialData() {
        let group = DispatchGroup()
        group.enter()
        loadQuests {
            self.quests = $0
            group.leave()
        }
        group.enter()
        loadRaidBosses {
            self.raidbosses = $0
            group.leave()
        }
        group.enter()
        User.load { user in
            self.user = user
            group.leave()
        }
        group.notify(queue: .main) {
            self.startUpDelegate?.didLoadInitialData()
        }
    }
    
    func loadUser() {
        User.load { user in
            self.user = user
        }
    }
    
    func savePokestop(_ pokestop: Pokestop) {
        let data = try! FirebaseEncoder().encode(pokestop)
        pokestopsRef.child(pokestop.geohash).childByAutoId().setValue(data)
    }
    
    func saveArena(_ arena: Arena) {
        let data = try! FirebaseEncoder().encode(arena)
        arenasRef.child(arena.geohash).childByAutoId().setValue(data)
    }
    
    func saveQuest(quest: Quest, for pokestop: Pokestop) {
        guard let pokestopID = pokestop.id else { return }
        let data = try! FirebaseEncoder().encode(quest)
        var dataWithTimestamp = data as! [String: Any]
        dataWithTimestamp["timestamp"] = ServerValue.timestamp()
        pokestopsRef.child(pokestop.geohash).child(pokestopID).child("quest").setValue(dataWithTimestamp)
    }
    
    func saveRaid(arena: Arena) {
        guard let arenaID = arena.id else { return }
        let data = try! FirebaseEncoder().encode(arena.raid)
        var dataWithTimestamp = data as! [String: Any]
        dataWithTimestamp["timestamp"] = ServerValue.timestamp()
        arenasRef.child(arena.geohash).child(arenaID).child("raid").setValue(dataWithTimestamp)
    }
    
    func saveRaidMeetup(raidMeetup: RaidMeetup) -> String {
        let data = try! FirebaseEncoder().encode(raidMeetup)
        let ref = Database.database().reference(withPath: "raidMeetups")
        let createId = ref.childByAutoId()
        createId.setValue(data)
        return createId.key!
    }
    
    private func saveToDatabase(data: [String: Any], geohash: String, id: String? = nil) {
        if isSignedIn {
            if let id = id {
                pokestopsRef.child(geohash).child(id).child("quest").setValue(data)
            } else {
                pokestopsRef.child(geohash).childByAutoId().setValue(data)
            }
            print("🔥✅ Did write to database")
        } else {
            print("🔥❌ Not authenticated, can not write to database")
        }
    }
    
    func loadPokestops(for geohash: String) {
        guard geohash != "" else { return }
        pokestopsRef.child(geohash).removeAllObservers()
        pokestopsRef.child(geohash).observe(.value, with: { snapshot in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for child in result {
                    guard let pokestop: Pokestop = decode(from: child) else { continue }
                    
                    if let localPokestop = self.pokestops[pokestop.id] {
                        if localPokestop == pokestop { continue }
                        print("Updated Pokestop")
                        self.pokestops[pokestop.id] = pokestop
                        self.delegate?.didUpdatePokestop(pokestop: pokestop)
                    } else {
                        print("Added Pokestop")
                        self.pokestops[pokestop.id] = pokestop
                        self.delegate?.didAddPokestop(pokestop: pokestop)
                    }
                }
            }
        })
    }
    
    func loadArenas(for geohash: String) {
        guard geohash != "" else { return }
        arenasRef.child(geohash).removeAllObservers()
        arenasRef.child(geohash).observe(.value, with: { snapshot in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for child in result {
                    guard let arena: Arena = decode(from: child) else { continue }
                    
                    if let localArena = self.arenas[arena.id] {
                        if localArena == arena { continue }
                        print("Updated Arena")
                        self.arenas[arena.id] = arena
                        self.delegate?.didUpdateArena(arena: arena)
                    } else {
                        print("Added Arena")
                        self.arenas[arena.id] = arena
                        self.delegate?.didAddArena(arena: arena)
                    }
                }
            }
        })
    }
    
    func subscribeForPush(for geohash: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        guard let notificationToken = user?.notificationToken else { return }
        let data = [notificationToken : userID]
        let geohashRegionPokestop = Database.database().reference(withPath: "pokestops/\(geohash)")
        geohashRegionPokestop.child("registered_user").updateChildValues(data)
        let geohashRegionArena = Database.database().reference(withPath: "arenas/\(geohash)")
        geohashRegionArena.child("registered_user").updateChildValues(data)
    }
    
    func loadRaidBosses(completion: @escaping ([RaidbossDefinition]) -> ()) {
        let raidbosses = Database.database().reference(withPath: "raidBosses")
        raidbosses.observeSingleEvent(of: .value) { snapshot in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                var raidbosses = [RaidbossDefinition]()
                
                for child in result {
                    guard let raidboss: RaidbossDefinition = decode(from: child) else { continue }
                    raidbosses.append(raidboss)
                }
                completion(raidbosses)
            }
        }
    }
    
    func loadQuests(completion: @escaping ([QuestDefinition]) -> ()) {
        let quests = Database.database().reference(withPath: "quests")
        quests.observeSingleEvent(of:.value) { snapshot in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                var quests = [QuestDefinition]()
                for child in result {
                    guard let quest: QuestDefinition = decode(from: child) else { continue }
                    quests.append(quest)
                }
                completion(quests)
            }
        }
    }
    
    @discardableResult
    func userParticipates(in raid: Raid, for arena: inout Arena) -> Arena {
        
        if let meetupId = raid.raidMeetupId {
            guard let id = raidMeetupsRef.childByAutoId().key,
                  let userId = user?.id else { fatalError() }
            let data = [id : userId]
            raidMeetupsRef.child(meetupId).child("participants").updateChildValues(data)
        } else {
            let meetupId = saveRaidMeetup(raidMeetup: RaidMeetup())
            associateMeetupIdToRaid(id: meetupId, arena: &arena)
            saveUserInRaidMeetup(for: meetupId)
        }
        return arena
    }
    
    private func associateMeetupIdToRaid(id: String, arena: inout Arena) {
        arena.raid?.raidMeetupId = id
        arenasRef.child(arena.geohash).child(arena.id).child("raid").updateChildValues(["raidMeetupId" : id])
    }
    
    private func saveUserInRaidMeetup(for id: String) {
        guard let userKey = raidMeetupsRef.childByAutoId().key,
              let userId = user?.id else { fatalError() }
        let data1 = [userKey: userId]
        raidMeetupsRef.child(id).child("participants").updateChildValues(data1)
    }
    
    func userCanceled(in meetup: RaidMeetup) {
        if let userKeys = meetup.participants?.keys.makeIterator() {
            if let participants = meetup.participants {
                for userKey in userKeys {
                    if participants[userKey] == user?.id {
                        raidMeetupsRef.child(meetup.id).child("participants").child(userKey).removeValue()
                    }
                }
            }
        }
    }

    func sendMessage(_ message: ChatMessage, in arena: inout Arena) {
        
        let sendMessage: (_ id: String) -> Void = { id in
            let data = try! FirebaseEncoder().encode(message)
            var dataWithTimestamp = data as! [String: Any]
            dataWithTimestamp["timestamp"] = ServerValue.timestamp()
            self.raidMeetupsRef.child(id).child("chat").childByAutoId().setValue(dataWithTimestamp)
        }
        
        if let meetupId = arena.raid?.raidMeetupId {
            sendMessage(meetupId)
        } else {
            let meetupId = saveRaidMeetup(raidMeetup: RaidMeetup())
            associateMeetupIdToRaid(id: meetupId, arena: &arena)
            sendMessage(meetupId)
        }
    }
    
    func user(for id: String, completion: @escaping (User) -> ()) {
        usersRef.child(id).observeSingleEvent(of: .value) { snapshot in
            guard let user: User = decode(from: snapshot) else { return }
            completion(user)
        }
    }

    func observeRaidMeetup(for meetupId: String) {
        raidMeetupsRef.child(meetupId).removeAllObservers()
        raidMeetupsRef.child(meetupId).observe(.value, with: { snapshot in
            guard let meetup: RaidMeetup = decode(from: snapshot) else { return }
            self.raidMeetupDelegate?.didUpdateRaidMeetup(meetup)
        })
    }

    func observeRaidChat(for meetupId: String) {
        raidMeetupsRef.child(meetupId).child("chat").removeAllObservers()
        raidMeetupsRef.child(meetupId).child("chat").observe(.value, with: { snapshot in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for child in result {
                    guard let chatMessage: ChatMessage = decode(from: child) else { continue }
                    self.raidChatDelegate?.didReceiveNewChatMessage(chatMessage)
                }
            }
        })
    }

    func loadUser(for id: String, completion: @escaping (User) -> Void) {
        user(for: id) { user in
            completion(user)
        }
    }

    /// DEBUG
    func addQuest(_ data: [String : String]) {
        let quests = Database.database().reference(withPath: "quests")
        quests.childByAutoId().setValue(data)
    }
    
    func addRaidBoss(_ data: [String : String]) {
        let quests = Database.database().reference(withPath: "raidBosses")
        quests.childByAutoId().setValue(data)
    }
    /// End DEBUG

    private func checkConnectivity() {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                self.connectivityTimer?.invalidate()
                let banner = NotificationBanner(title: "Vebunden zum Server", subtitle: "Viel Spaß Trainer!", style: .success)
                banner.show()
            } else {
                self.connectivityTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { timer in
                    let banner = NotificationBanner(title: "Keine Verbindung zum Server", subtitle: "Prüfe bitte deine Internetverbindung", style: .danger)
                    banner.show()
                })
            }
        })
    }
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
    var firebaseConnector: FirebaseConnector! { get set }
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
