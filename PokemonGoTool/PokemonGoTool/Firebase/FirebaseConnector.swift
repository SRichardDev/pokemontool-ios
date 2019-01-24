
import Foundation
import Firebase
import FirebaseMessaging
import CodableFirebase

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
