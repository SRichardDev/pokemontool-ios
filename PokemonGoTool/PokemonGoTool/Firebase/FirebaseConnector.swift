
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
    func didUpdateAnnotation(newAnnotation: Annotation)
}

protocol FirebaseUserDelegate {
    func didUpdateUser()
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
    var delegate: FirebaseDelegate?
    var userDelegate: FirebaseUserDelegate?
    var isSignedIn: Bool {
        return Auth.auth().currentUser?.uid != nil ? true : false
    }
    
    init() {
        loadUser()
        pokestopsRef = Database.database().reference(withPath: "pokestops")
        arenasRef = Database.database().reference(withPath: "arenas")
        checkConnectivity()
//        addRaidBosses()
//        addQuests()
        
        loadQuests { quests in
            guard let quests = quests else { return }
            self.quests = quests
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
        pokestopsRef.child(pokestop.geohash).child(pokestopID).child("quest").setValue(data)
    }
    
    func saveRaid(arena: Arena) {
        guard let arenaID = arena.id else { return }
        let data = try! FirebaseEncoder().encode(arena.raid)
        arenasRef.child(arena.geohash).child(arenaID).child("raid").setValue(data)
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
    
    func loadRaidBosses(for level: Int, completion: @escaping ([[String]]?) -> ()) {
        var raidBossesArray = [[String]]()
        let raidbosses = Database.database().reference(withPath: "raidBosses")
        raidbosses.child("level\(level)").observeSingleEvent(of: .value) { snapshot in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for child in result {
                    let number = child.key
                    let pokemonName = child.value as! String
                    raidBossesArray.append([number,pokemonName])
                }
                completion(raidBossesArray)
            }
        }
    }
    
    func loadQuests(completion: @escaping ([QuestDefinition]?) -> ()) {
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
        let level5Data = ["484" : "Palkia"]
        let level4Data = ["105" : "Alola Knogga",
                          "176" : "Togetic",
                          "217" : "Ursaring",
                          "248" : "Despotar",
                          "359" : "Absol"]
        let level3Data = ["65" : "Simsala",
                          "68" : "Machomei",
                          "184" : "Azumarill",
                          "210" : "Granbull"]
        let level2Data = ["103" : "Alola Kokowei",
                          "281" : "Kirilia",
                          "302" : "Zobiris",
                          "303" : "Flunkifer"]
        let level1Data = ["129" : "Karpador",
                          "147" : "Dratini",
                          "333" : "Wablu",
                          "349" : "Barschwa",
                          "403" : "Shinux",
                          "418" : "Bamelin"]
        let raidbosses = Database.database().reference(withPath: "raidBosses")
        raidbosses.child("level5").updateChildValues(level5Data)
        raidbosses.child("level4").updateChildValues(level4Data)
        raidbosses.child("level3").updateChildValues(level3Data)
        raidbosses.child("level2").updateChildValues(level2Data)
        raidbosses.child("level1").updateChildValues(level1Data)
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
