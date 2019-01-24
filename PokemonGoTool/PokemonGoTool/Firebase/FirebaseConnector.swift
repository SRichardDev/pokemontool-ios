
import Foundation
import Firebase
import FirebaseMessaging

protocol FirebaseDelegate {
    func didUpdatePokestops()
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
    }
    
    func savePokestop(_ pokestop: Pokestop) {
        let data = ["name"        : pokestop.name,
                    "latitude"    : pokestop.latitude.string,
                    "longitude"   : pokestop.longitude.string,
                    "submitter"   : user?.trainerName ?? "Unknown",
                    "submitterId" : user?.id ?? "Unknown"]
        saveToDatabase(data: data, geohash: pokestop.geohash)
    }
    
    func saveArena(_ arena: Arena) {
        let data = ["name"        : arena.name,
                    "latitude"    : arena.latitude.string,
                    "longitude"   : arena.longitude.string,
                    "submitter"   : user?.trainerName ?? "Unknown",
                    "submitterId" : user?.id ?? "Unknown"]
    }
    
    func saveQuest(quest: Quest, for pokestop: Pokestop) {
        guard let pokestopID = pokestop.id else {return}
        let data = ["name"      : quest.name,
                    "reward"    : quest.reward,
                    "submitter" : quest.submitter]
        saveToDatabase(data: data, geohash: pokestop.geohash, id: pokestopID)
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
    
    func loadPokestops(for geoHash: String) {
        guard geoHash != "" else { return }
        pokestops.removeAll()
        pokestopsRef.child(geoHash).observe(.value, with: { snapshot in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for child in result {
                    let values = child.value as! [String: Any]
                    guard let name = values["name"] as? String else { return }
                    let latitude = Double(values["latitude"] as! String)!
                    let longitude = Double(values["longitude"] as! String)!
                    let submitter = values["submitter"] as! String
                    let questChildren = child.childSnapshot(forPath: "quest")
            
                    var questName = ""
                    var reward = ""
                    var questSubmitter = ""
                    
                    if let quest = questChildren.value as? [String: Any] {
                        questName = quest["name"] as! String
                        reward = quest["reward"] as! String
                        questSubmitter = quest["submitter"] as! String
                    }
                    
                    let quest1 = Quest(name: questName, reward: reward, submitter: questSubmitter)
                    
                    
                    let pokestop = Pokestop(name: name,
                                            latitude: latitude,
                                            longitude: longitude,
                                            submitter: submitter,
                                            id: child.key,
                                            quest: quest1,
                                            upVotes: 0,
                                            downVotes: 0)
                    
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
    
    func subscribeForPush(for geohash: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let user = Database.database().reference(withPath: "pokestops/\(geohash)")
        let data = [userID : userID]
        user.child("registered_user").updateChildValues(data)
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
