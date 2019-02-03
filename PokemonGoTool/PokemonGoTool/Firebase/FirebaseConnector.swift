
import Foundation
import Firebase
import FirebaseMessaging
import CodableFirebase

protocol FirebaseDelegate {
    func didUpdatePokestops()
    func didUpdateArenas()
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
    
    var pokestops = [Pokestop]()
    var arenas = [Arena]()
    var delegate: FirebaseDelegate?
    var userDelegate: FirebaseUserDelegate?
    var isSignedIn: Bool {
        return Auth.auth().currentUser?.uid != nil ? true : false
    }
    
    init() {
        User.loadUser { user in
            self.user = user
        }
        pokestopsRef = Database.database().reference(withPath: "pokestops")
        arenasRef = Database.database().reference(withPath: "arenas")
        
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                print("Connected")
            } else {
                print("Not connected")
            }
        })
        
//        addRaidBosses()
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
        pokestops.removeAll()
        pokestopsRef.child(geohash).observe(.value, with: { snapshot in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for child in result {
                    guard let pokestop: Pokestop = decode(from: child) else { continue }
                    var pokestopAlreadySaved = false
                    self.pokestops.forEach { savedPokestop in
                        if pokestop.id == savedPokestop.id {
                            pokestopAlreadySaved = true
                        }
                    }
                    if !pokestopAlreadySaved {
                        self.pokestops.append(pokestop)
                    }
                }
                self.delegate?.didUpdatePokestops()
            }
        })
    }
    
    func loadArenas(for geohash: String) {
        guard geohash != "" else { return }
        arenas.removeAll()
        arenasRef.child(geohash).observe(.value, with: { snapshot in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for child in result {
                    guard let arena: Arena = decode(from: child) else { continue }
                    var arenaAlreadySaved = false
                    self.arenas.forEach { savedArena in
                        if arena.id == savedArena.id {
                            arenaAlreadySaved = true
                        }
                    }
                    if !arenaAlreadySaved {
                        self.arenas.append(arena)
                    }
                }
                self.delegate?.didUpdateArenas()
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
    
    func loadRaidBosses(for level: Int, completion: @escaping ([String]?) -> ()) {
        var raidBossesArray = [String]()
        let raidbosses = Database.database().reference(withPath: "raidBosses")
        raidbosses.child("level\(level)").observeSingleEvent(of: .value) { snapshot in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for child in result {
                    raidBossesArray.append(child.value as! String)
                }
                completion(raidBossesArray)
            }
        }
    }
    
    func addRaidBosses() {
        let level5Data = ["484" : "Palkia"]
        let level4Data = ["105" : "Alola Knogga",
                          "176" : "Togetic",
                          "217" : "Ursaring",
                          "248" : "Despotar",
                          "359" : "Absol"]
        let level3Data = ["1" : "Simsala",
                          "2" : "Machomei",
                          "3" : "Azumarill",
                          "4" : "Granbull"]
        let level2Data = ["1" : "Alola Kokowei",
                          "2" : "Kirilia",
                          "3" : "Zobiris",
                          "4" : "Flunkifer"]
        let level1Data = ["1" : "Karpador",
                          "2" : "Dratini",
                          "3" : "Wablu",
                          "4" : "Barschwa",
                          "5" : "Shinux",
                          "6" : "Bamelin"]
        let raidbosses = Database.database().reference(withPath: "raidBosses")
        raidbosses.child("level5").updateChildValues(level5Data)
        raidbosses.child("level4").updateChildValues(level4Data)
        raidbosses.child("level3").updateChildValues(level3Data)
        raidbosses.child("level2").updateChildValues(level2Data)
        raidbosses.child("level1").updateChildValues(level1Data)

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
