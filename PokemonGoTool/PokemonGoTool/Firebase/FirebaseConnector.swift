
import Foundation
import Firebase
import FirebaseMessaging
import CodableFirebase

class FirebaseConnector {
    
    private let pokestopsRef = Database.database().reference(withPath: DatabaseKeys.pokestops)
    private let arenasRef = Database.database().reference(withPath: DatabaseKeys.arenas)
    private let raidMeetupsRef = Database.database().reference(withPath: DatabaseKeys.raidMeetups)
    private let usersRef = Database.database().reference(withPath: DatabaseKeys.users)
    private let questsRef = Database.database().reference(withPath: DatabaseKeys.quests)
    private let raidBossesRef = Database.database().reference(withPath: DatabaseKeys.raidBosses)

    private(set) var user: User? {
        didSet {
            userDelegate?.didUpdateUser()
        }
    }
    
    private var connectivityTimer: Timer?
    var pokestops: [String: Pokestop] = [:]
    var arenas: [String: Arena] = [:]
    var quests = [QuestDefinition]()

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
    }
    
    private func loadInitialData() {
        loadUser(){}
    
        let group = DispatchGroup()
        group.enter()
        loadQuests {
            self.quests = $0
            group.leave()
        }
        group.enter()
        loadRaidBosses {
            RaidbossManager.shared.raidbosses = $0
            group.leave()
        }

        group.notify(queue: .main) {
            self.startUpDelegate?.didLoadInitialData()
        }
    }
    
    func loadUser(completion: @escaping () -> Void) {
        User.load { user in
            self.user = user
            completion()
        }
    }
    
    func savePokestop(_ pokestop: Pokestop) {
        let data = try! FirebaseEncoder().encode(pokestop)
        let newRef = pokestopsRef.child(pokestop.geohash).childByAutoId()
        newRef.setValue(data)
        guard let key = newRef.key else { fatalError() }
        user?.saveSubmittedPokestopId(key, for: pokestop.geohash)
    }
    
    func saveArena(_ arena: Arena) {
        let data = try! FirebaseEncoder().encode(arena)
        let newRef = arenasRef.child(arena.geohash).childByAutoId()
        newRef.setValue(data)
        guard let key = newRef.key else { fatalError() }
        user?.saveSubmittedArena(key, for: arena.geohash)
    }
    
    func saveQuest(quest: Quest, for pokestop: Pokestop) {
        guard let pokestopID = pokestop.id else { return }
        let data = try! FirebaseEncoder().encode(quest)
        var dataWithTimestamp = data as! [String: Any]
        dataWithTimestamp[DatabaseKeys.timestamp] = ServerValue.timestamp()
        pokestopsRef
            .child(pokestop.geohash)
            .child(pokestopID)
            .child(DatabaseKeys.quest)
            .setValue(dataWithTimestamp)
        
        user?.updateSubmittedQuestCount()
    }
    
    func saveRaid(arena: Arena) {
        guard let arenaID = arena.id else { return }
        let data = try! FirebaseEncoder().encode(arena.raid)
        var dataWithTimestamp = data as! [String: Any]
        dataWithTimestamp[DatabaseKeys.timestamp] = ServerValue.timestamp()
        arenasRef
            .child(arena.geohash)
            .child(arenaID)
            .child(DatabaseKeys.raid)
            .setValue(dataWithTimestamp)
        
        user?.updateSubmittedRaidCount()
    }
    
    func saveRaidMeetup(raidMeetup: RaidMeetup) -> String {
        let data = try! FirebaseEncoder().encode(raidMeetup)
        let ref = Database.database().reference(withPath: DatabaseKeys.raidMeetups)
        let createId = ref.childByAutoId()
        createId.setValue(data)
        return createId.key!
    }
    
    func loadPokestops(for geohash: String) {
        if AppSettings.filterSettingsChanged {
            pokestops.removeAll()
            arenas.removeAll()
            AppSettings.filterSettingsChanged = false
        }
        
        guard geohash != "" else { return }
        pokestopsRef
            .child(geohash)
            .removeAllObservers()
        
        pokestopsRef
            .child(geohash)
            .observe(.value, with: { snapshot in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for child in result {
                    guard let pokestop: Pokestop = decode(from: child) else { continue }
                    
                    if let localPokestop = self.pokestops[pokestop.id] {
                        if localPokestop == pokestop { continue }
                        self.pokestops[pokestop.id] = pokestop
                        self.delegate?.didUpdatePokestop(pokestop: pokestop)
                    } else {
                        self.pokestops[pokestop.id] = pokestop
                        self.delegate?.didAddPokestop(pokestop: pokestop)
                    }
                }
            }
        })
    }
    
    func loadArenas(for geohash: String) {
        guard geohash != "" else { return }
        arenasRef
            .child(geohash)
            .removeAllObservers()
        arenasRef
            .child(geohash)
            .observe(.value, with: { snapshot in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for child in result {
                    guard var arena: Arena = decode(from: child) else { continue }
                    
                    arena.isGoldArena = self.user?.goldArenas?.keys.contains(arena.id) ?? false
                    
                    if let localArena = self.arenas[arena.id] {
                        if localArena == arena { continue }
                        self.arenas[arena.id] = arena
                        self.delegate?.didUpdateArena(arena: arena)
                    } else {
                        self.arenas[arena.id] = arena
                        self.delegate?.didAddArena(arena: arena)
                    }
                }
            }
        })
    }
    
    func subscribeForPush(for geohash: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let data = [userID : ""]
        
        pokestopsRef
            .child(geohash)
            .child(DatabaseKeys.registeredUser)
            .updateChildValues(data)
        
        arenasRef
            .child(geohash)
            .child(DatabaseKeys.registeredUser)
            .updateChildValues(data)
        
        user?.addGeohashForPushSubscription(for: .pokestop, geohash: geohash)
    }
    
    func unsubscribeForPush(for geohash: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        pokestopsRef
            .child(geohash)
            .child(DatabaseKeys.registeredUser)
            .child(userID)
            .removeValue()
        
        arenasRef
            .child(geohash)
            .child(DatabaseKeys.registeredUser)
            .child(userID)
            .removeValue()
        
        user?.removeGeohashForPushSubsription(for: .pokestop, geohash: geohash)
    }
    
    func loadRaidBosses(completion: @escaping ([RaidbossDefinition]) -> ()) {
        raidBossesRef.observeSingleEvent(of: .value) { snapshot in
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
        questsRef.observeSingleEvent(of:.value) { snapshot in
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
            guard let userId = user?.id else { fatalError() }
            let data = [userId: ""]
            raidMeetupsRef
                .child(meetupId)
                .child(DatabaseKeys.participants)
                .updateChildValues(data)
        } else {
            let meetupId = saveRaidMeetup(raidMeetup: RaidMeetup())
            associateMeetupIdToRaid(id: meetupId, arena: &arena)
            saveUserInRaidMeetup(for: meetupId)
        }
        return arena
    }
    
    private func associateMeetupIdToRaid(id: String, arena: inout Arena) {
        arena.raid?.raidMeetupId = id
        arenasRef
            .child(arena.geohash)
            .child(arena.id)
            .child(DatabaseKeys.raid)
            .updateChildValues([DatabaseKeys.raidMeetupId : id])
    }
    
    private func saveUserInRaidMeetup(for id: String) {
        guard let userId = user?.id else { fatalError() }
        let data = [userId: ""]
        raidMeetupsRef
            .child(id)
            .child(DatabaseKeys.participants)
            .updateChildValues(data)
    }
    
    func userCanceled(in meetup: RaidMeetup) {
        if let userKeys = meetup.participants?.keys {
            if let participants = meetup.participants {
                userKeys.forEach { userKey in
                    guard let userId = user?.id else { fatalError() }
                    if participants[userId] != nil {
                        raidMeetupsRef
                            .child(meetup.id)
                            .child(DatabaseKeys.participants)
                            .child(userKey)
                            .removeValue()
                    }
                }
            }
        }
    }

    func sendMessage(_ message: ChatMessage, in arena: inout Arena) {
        
        let sendMessage: (_ id: String) -> Void = { id in
            let data = try! FirebaseEncoder().encode(message)
            var dataWithTimestamp = data as! [String: Any]
            dataWithTimestamp[DatabaseKeys.timestamp] = ServerValue.timestamp()
            self.raidMeetupsRef
                .child(id)
                .child(DatabaseKeys.chat)
                .childByAutoId()
                .setValue(dataWithTimestamp)
        }
        
        if let meetupId = arena.raid?.raidMeetupId {
            sendMessage(meetupId)
        } else {
            let meetupId = saveRaidMeetup(raidMeetup: RaidMeetup())
            associateMeetupIdToRaid(id: meetupId, arena: &arena)
            sendMessage(meetupId)
        }
    }
    
    func user(for id: String, completion: @escaping (PublicUserData) -> ()) {
        usersRef
            .child(id)
            .child(DatabaseKeys.publicUserData)
            .observeSingleEvent(of: .value) { snapshot in
            guard let user: PublicUserData = decode(from: snapshot) else { return }
            completion(user)
        }
    }
    
    func userName(for id: String, completion: @escaping (String) -> ()) {
        usersRef
            .child(id)
            .child(DatabaseKeys.trainerName)
            .observeSingleEvent(of: .value) { snapshot in
            if let trainerName = snapshot.value as? String {
                completion(trainerName)
            }
        }
    }

    func observeRaidMeetup(for meetupId: String) {
        raidMeetupsRef
            .child(meetupId)
            .removeAllObservers()
        
        raidMeetupsRef
            .child(meetupId)
            .observe(.value, with: { snapshot in
            guard let meetup: RaidMeetup = decode(from: snapshot) else { return }
            self.raidMeetupDelegate?.didUpdateRaidMeetup(meetup)
        })
    }

    func observeRaidChat(for meetupId: String) {
        raidMeetupsRef
            .child(meetupId)
            .child(DatabaseKeys.chat)
            .removeAllObservers()
        
        raidMeetupsRef
            .child(meetupId)
            .child(DatabaseKeys.chat)
            .observe(.value, with: { snapshot in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for child in result {
                    guard let chatMessage: ChatMessage = decode(from: child) else { continue }
                    self.raidChatDelegate?.didReceiveNewChatMessage(chatMessage)
                }
            }
        })
    }

    func loadPublicUserData(for id: String, completion: @escaping (PublicUserData) -> Void) {
        user(for: id) { user in
            completion(user)
        }
    }

    private func checkConnectivity() {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                self.connectivityTimer?.invalidate()
                NotificationBannerManager.shared.show(.connected)
            } else {
                self.connectivityTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { timer in
                    NotificationBannerManager.shared.show(.disconnected)
                })
            }
        })
    }
    
    func updateArena(_ arena: Arena) {
        self.arenas[arena.id] = arena
        self.delegate?.didUpdateArena(arena: arena)
    }
    
    /// DEBUG
    func addQuest(_ data: [String : String]) {
        let quests = Database.database().reference(withPath: DatabaseKeys.quests)
        quests.childByAutoId().setValue(data)
    }
    
    func addRaidBoss(_ data: [String : String]) {
        let quests = Database.database().reference(withPath: DatabaseKeys.raidBosses)
        quests.childByAutoId().setValue(data)
    }
    /// End DEBUG
}
