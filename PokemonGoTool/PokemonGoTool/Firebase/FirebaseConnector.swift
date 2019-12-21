
import Foundation
import Firebase
import FirebaseMessaging
import CodableFirebase

class FirebaseConnector {
    
    let chatConnector = ChatConnector()
    
    private let pokestopsRef = Database.database().reference(withPath: DatabaseKeys.pokestops)
    private let arenasRef = Database.database().reference(withPath: DatabaseKeys.arenas)
    private let usersRef = Database.database().reference(withPath: DatabaseKeys.users)
    private let questsRef = Database.database().reference(withPath: DatabaseKeys.quests)
    private let registeredUsersPokestopsRef = Database.database().reference(withPath: DatabaseKeys.registeredUsersPokestops)
    private let registeredUsersArenasRef = Database.database().reference(withPath: DatabaseKeys.registeredUsersArenas)

    private let testPokestopsRef = Database.database().reference(withPath: DatabaseKeys.testpokestops)
    private let testArenasRef = Database.database().reference(withPath: DatabaseKeys.testarenas)
    private var topicSubscriptionManager = TopicSubscriptionManager()
    
    private(set) var user: User? {
        didSet {
            Migrator(firebaseConnector: self)
            userDelegate?.didUpdateUser()
        }
    }
    
    private var connectivityTimer: Timer?
    var quests = [QuestDefinition]()

    weak var userDelegate: FirebaseUserDelegate?
    weak var startUpDelegate: FirebaseStartupDelegate?
    weak var raidDelegate: RaidDelegate?

    var isSignedIn: Bool {
        return Auth.auth().currentUser?.uid != nil ? true : false
    }
    
    init() {
        questsRef.keepSynced(true)
        checkConnectivity()
        loadInitialData()
    }
    
    private func loadInitialData() {
    
        let group = DispatchGroup()
        group.enter()
        User.load { user in
            self.user = user
            group.leave()
        }
        group.enter()
        loadQuests {
            self.quests = $0
            group.leave()
        }

        group.notify(queue: .main) {
            self.observerUser()
            self.startUpDelegate?.didLoadInitialData()
            self.user?.cleanupMeetupSubscriptionsIfNeeded()
            self.user?.saveAppLastOpened()
        }
    }
    
    func loadUser(completion: @escaping () -> Void) {
        User.load { user in
            self.user = user
            self.observerUser()
            completion()
        }
    }
    
    func observerUser() {
        User.observe { user in
            self.user = user
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
    
    func subscribeToTopic(_ topic: String, topicType: TopicType) {
        guard let user = user else { return }
        topicSubscriptionManager.subscribeToTopic(for: user, in: topic, for: topicType)
    }
    
    func unsubscribeFormTopic(_ topic: String, topicType: TopicType) {
        guard let user = user else { return }
        topicSubscriptionManager.unsubscribeFromTopic(for: user, in: topic, for: topicType)
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
    func userParticipatesInRaid(in arena: inout Arena) -> Arena {
        guard let userId = user?.id else { fatalError() }
        let data = [userId: ""]
        arenasRef
            .child(arena.geohash)
            .child(arena.id)
            .child(DatabaseKeys.raid)
            .child(DatabaseKeys.meetup)
            .child(DatabaseKeys.participants)
            .updateChildValues(data)
        
        #warning("TODO: subscribe to topic")
        return arena
    }
    
    func userCanceledInRaid(in arena: inout Arena) {
        guard let userId = user?.id else { fatalError() }
        arenasRef
            .child(arena.geohash)
            .child(arena.id)
            .child(DatabaseKeys.raid)
            .child(DatabaseKeys.meetup)
            .child(DatabaseKeys.participants)
            .child(userId)
            .removeValue()
        #warning("TODO: unsubscribe from topic")

    }
    
    func setMeetupTime(_ meetupTime: TimeInterval, in arena: Arena) {
        let data = [DatabaseKeys.meetupTime: meetupTime]
        arenasRef
            .child(arena.geohash)
            .child(arena.id)
            .child(DatabaseKeys.raid)
            .child(DatabaseKeys.meetup)
            .updateChildValues(data)
    }
    
    func deleteOldChat(for id: String) {
        #warning("TODO: Delete old chat")
    }
    
//    func setRaidbossForRaid(in arena: inout Arena, raidboss: RaidbossDefinition) {
//        guard let raidbossId = raidboss.id else { return }
//        arena.raid?.raidBossId = raidbossId
//        arenasRef
//            .child(arena.geohash)
//            .child(arena.id)
//            .child(DatabaseKeys.raid)
//            .updateChildValues([DatabaseKeys.raidBossId : raidbossId])
//    }
    
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
            .child(DatabaseKeys.publicUserData)
            .child(DatabaseKeys.trainerName)
            .observeSingleEvent(of: .value) { snapshot in
            if let trainerName = snapshot.value as? String {
                completion(trainerName)
            }
        }
    }

    func observeRaid(in arena: Arena) {
        arenasRef
            .child(arena.geohash)
            .child(arena.id)
            .child(DatabaseKeys.raid)
            .observe(.value) { snapshot in
                guard let raid: Raid = decode(from: snapshot) else { return }
                self.raidDelegate?.didUpdateRaid(raid)
        }
    }
    
    func loadPublicUserData(for id: String, completion: @escaping (PublicUserData) -> Void) {
        user(for: id) { user in
            completion(user)
        }
    }
    
    func clearRaidIfExpired(for arena: Arena) {
        guard let raid = arena.raid else { return }
        if raid.isExpired {
            arenasRef
                .child(arena.geohash)
                .child(arena.id)
                .child(DatabaseKeys.raid)
                .removeValue()
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
    
    #warning("FIX: GOLD ARENA")
    func updateArena(_ arena: Arena) {
//        self.arenas[arena.id] = arena
//        self.delegate?.didUpdateArena(arena: arena)
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
    
    func DEBUGdeleteArena(_ arena: Arena) {
        arenasRef
            .child(arena.geohash)
            .child(arena.id)
            .removeValue()
    }
    /// End DEBUG
}
