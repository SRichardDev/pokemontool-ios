
import Foundation
import Firebase
import FirebaseMessaging
import CodableFirebase
import NotificationBannerSwift

protocol FirebaseDelegate {
    func didAddPokestop(pokestop: Pokestop)
    func didUpdatePokestop(pokestop: Pokestop)
    func didAddArena(arena: Arena)
    func didUpdateArena(arena: Arena)
}

protocol FirebaseUserDelegate {
    func didUpdateUser()
}

protocol FirebaseStartupDelegate {
    func didLoadInitialData()
}

protocol FirebaseStatusPresentable {
    var firebaseConnector: FirebaseConnector! { get set }
}

class FirebaseConnector {
    
    private var pokestopsRef: DatabaseReference!
    private var arenasRef: DatabaseReference!

    
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
    var delegate: FirebaseDelegate?
    var userDelegate: FirebaseUserDelegate?
    var startUpDelegate: FirebaseStartupDelegate?
    var isSignedIn: Bool {
        return Auth.auth().currentUser?.uid != nil ? true : false
    }
    
    init() {
        checkConnectivity()
        loadInitialData()
        pokestopsRef = Database.database().reference(withPath: "test_pokestops")
        arenasRef = Database.database().reference(withPath: "arenas")
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
    
    func saveRaidMeetup(raidMeetup: RaidMeetup) -> String? {
        let data = try! FirebaseEncoder().encode(raidMeetup)
        let ref = Database.database().reference(withPath: "raidMeetups")
        let createId = ref.childByAutoId()
        createId.setValue(data)
        return createId.key
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
    
    private func addRaidBosses() {
        let palkia = ["name": "Palkia",
                      "level": "5",
                      "imageName" : "484"]
        let latias = ["name": "Latias",
                      "level": "5",
                      "imageName" : "380"]
        
        let knogga = ["name": "Alola Knogga",
                      "level": "4",
                      "imageName" : "105"]
        let togetic = ["name": "Togetic",
                       "level": "4",
                       "imageName" : "176"]
        let ursaring = ["name": "Ursaring",
                        "level": "4",
                        "imageName" : "217"]
        let despotar = ["name": "Despotar",
                        "level": "4",
                        "imageName" : "248"]
        let absol = ["name": "Absol",
                     "level": "4",
                     "imageName" : "359"]
        let simsala = ["name": "Simsala",
                       "level": "4",
                       "imageName" : "65"]
        
        
        
        
        let machomei = ["name": "Machomei",
                        "level": "3",
                        "imageName" : "68"]
        let azumarill = ["name": "Azumarill",
                         "level": "3",
                         "imageName" : "184"]
        let granbull = ["name": "Granbull",
                        "level": "3",
                        "imageName" : "210"]
        
        
        
        let kokowei = ["name": "Alola Kokowei",
                        "level": "2",
                        "imageName" : "103"]
        let kirilia = ["name": "Kirilia",
                        "level": "2",
                        "imageName" : "281"]
        let zobiris = ["name": "Zobiris",
                        "level": "2",
                        "imageName" : "302"]
        let flunkifer = ["name": "Flunkifer",
                        "level": "2",
                        "imageName" : "303"]
        
        let karpador = ["name": "Karpador",
                        "level": "1",
                        "imageName" : "129"]
        let dratini = ["name": "Dratini",
                       "level": "1",
                       "imageName" : "147"]
        let wablu = ["name": "Wablu",
                     "level": "1",
                     "imageName" : "333"]
        let barschwa = ["name": "Barschwa",
                        "level": "1",
                        "imageName" : "349"]
        let shinux = ["name": "Shinux",
                      "level": "1",
                      "imageName" : "403"]
        let bamelin = ["name": "Bamelin",
                       "level": "1",
                       "imageName" : "418"]
        
        let raidbosses = Database.database().reference(withPath: "raidBosses")
        raidbosses.childByAutoId().updateChildValues(palkia)
        raidbosses.childByAutoId().updateChildValues(latias)
        raidbosses.childByAutoId().updateChildValues(absol)
        raidbosses.childByAutoId().updateChildValues(azumarill)
        raidbosses.childByAutoId().updateChildValues(bamelin)
        raidbosses.childByAutoId().updateChildValues(barschwa)
        raidbosses.childByAutoId().updateChildValues(despotar)
        raidbosses.childByAutoId().updateChildValues(dratini)
        raidbosses.childByAutoId().updateChildValues(flunkifer)
        raidbosses.childByAutoId().updateChildValues(granbull)
        raidbosses.childByAutoId().updateChildValues(karpador)
        raidbosses.childByAutoId().updateChildValues(kirilia)
        raidbosses.childByAutoId().updateChildValues(knogga)
        raidbosses.childByAutoId().updateChildValues(kokowei)
        raidbosses.childByAutoId().updateChildValues(machomei)
        raidbosses.childByAutoId().updateChildValues(shinux)
        raidbosses.childByAutoId().updateChildValues(simsala)
        raidbosses.childByAutoId().updateChildValues(togetic)
        raidbosses.childByAutoId().updateChildValues(ursaring)
        raidbosses.childByAutoId().updateChildValues(wablu)
        raidbosses.childByAutoId().updateChildValues(zobiris)
    }
    
    private func addQuests() {
        
        let quest1 = ["quest" : "Tausche 10 Pokémon",
                      "reward" : "Panflam",
                      "imageName" : "390"]
        let quest2 = ["quest" : "Fange 10 Pokémon von Typ Boden",
                      "reward" : "Sandan ✨",
                      "imageName" : "27"]
        let quest3 = ["quest" : "Lande 5 großartige Curveball-Würfe hintereinander",
                      "reward" : "Pandir (Form 5)",
                      "imageName" : "327"]
        let quest4 = ["quest" : "Brüte 5 Eier aus",
                      "reward" : "3 x Sonderbonbon",
                      "imageName" : "candy"]
        let quest5 = ["quest" : "Lande 3 fabelhafte Würfe hintereinander",
                      "reward" : "Larvitar ✨",
                      "imageName" : "246"]
        let quest6 = ["quest" : "Fange ein Pokémon vom Typ Drache",
                      "reward" : "Dratini ✨",
                      "imageName" : "147"]
        let quest7 = ["quest" : "Lande 3 großartige Curveball-Würfe hintereinander",
                      "reward" : "Onix",
                      "imageName" : "95"]

        let quests = Database.database().reference(withPath: "quests")
        quests.childByAutoId().setValue(quest1)
        quests.childByAutoId().setValue(quest2)
        quests.childByAutoId().setValue(quest3)
        quests.childByAutoId().setValue(quest4)
        quests.childByAutoId().setValue(quest5)
        quests.childByAutoId().setValue(quest6)
        quests.childByAutoId().setValue(quest7)
    }
    
    func addQuest(_ data: [String : String]) {
        let quests = Database.database().reference(withPath: "quests")
        quests.childByAutoId().setValue(data)
    }
    
    func addDummyPokestops() {
        for _ in 0...1000 {
            let latitude = Double.random(in: 48.0...48.3)
            let longitude = Double.random(in: 11.4...11.7)
            let pokestop = Pokestop(name: "foobar", latitude: latitude, longitude: longitude, submitter: "Test")
            savePokestop(pokestop)
        }
    }
    
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
