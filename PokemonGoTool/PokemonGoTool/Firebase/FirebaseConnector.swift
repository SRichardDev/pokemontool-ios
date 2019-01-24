
import Foundation
import Firebase
import FirebaseMessaging

protocol FirebaseDelegate {
    func didUpdatePokestops()
}

protocol FirebaseStatusPresentable {
    var firebaseConnector: FirebaseConnector! { get set }
}

class FirebaseConnector {
    
    private var database: DatabaseReference!
    var pokestops = [Pokestop]()
    private(set) var user: User?
    var delegate: FirebaseDelegate?
    
    var isSignedIn: Bool {
        return Auth.auth().currentUser?.uid != nil ? true : false
    }
    
    init() {
        database = Database.database().reference(withPath: "pokestops")
        User.loadUser(completion: { user in
            self.user = user
        })
    }
    
    func savePokestop(_ pokestop: Pokestop) {
        let data = ["name"      : pokestop.name,
                    "latitude"  : pokestop.latitude.string,
                    "longitude" : pokestop.longitude.string]
        
        saveToDatabase(data: data, geohash: pokestop.geohash)
    }
    
    func saveQuest(quest: Quest, for pokestop: Pokestop) {
        guard let pokestopID = pokestop.id else {return}
        let data = ["name" : quest.name,
                    "reward" : quest.reward,
                    "submitter" : quest.submitter]
        saveToDatabase(data: data, geohash: pokestop.geohash, id: pokestopID)
    }
    
    private func saveToDatabase(data: [String: Any], geohash: String) {
        if isSignedIn {
            database.child(geohash).childByAutoId().setValue(data)
            print("✅ Did write to database")
        } else {
            print("❌ Not authenticated, can not write to database")
        }
    }
    
    private func saveToDatabase(data: [String: Any], geohash: String, id: String) {
        if isSignedIn {
            database.child(geohash).child(id).child("quest").setValue(data)
            print("✅ Did write to database")
        } else {
            print("❌ Not authenticated, can not write to database")
        }
    }
    
    func loadPokestops(for geoHash: String) {
        guard geoHash != "" else { return }
        pokestops.removeAll()
        database.child(geoHash).observe(.value, with: { snapshot in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for child in result {
                    let values = child.value as! [String: Any]
                    guard let name = values["name"] as? String else { return }
                    let latitude = Double(values["latitude"] as! String)!
                    let longitude = Double(values["longitude"] as! String)!
                    
                    let questChildren = child.childSnapshot(forPath: "quest")
            
                    var questName = ""
                    var reward = ""
                    var submitter = ""
                    
                    if let quest = questChildren.value as? [String: Any] {
                        questName = quest["name"] as! String
                        reward = quest["reward"] as! String
                        submitter = quest["submitter"] as! String
                    }
                    
                    let quest1 = Quest(name: questName, reward: reward, submitter: submitter)
                    
                    
                    let pokestop = Pokestop(name: name,
                                            latitude: latitude,
                                            longitude: longitude,
                                            id: child.key,
                                            quest: quest1)
                    
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
    
    func signUpUser(with email: String, password: String, completion: @escaping (AuthStatus) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                if let errorCode = AuthErrorCode(rawValue: error._code) {
                    switch errorCode {
                    case .weakPassword:
                        completion(.weakPassword)
                    case .invalidCredential:
                        completion(.invalidCredential)
                    case .emailAlreadyInUse:
                        completion(.emailAlreadyInUse)
                    case .invalidEmail:
                        completion(.invalidEmail)
                    case .networkError:
                        completion(.networkError)
                    case .missingEmail:
                        completion(.missingEmail)
                    default:
                        completion(.unknown(error: error.localizedDescription))
                    }
                }
                print(error.localizedDescription)
            }
            
            guard let result = result else { completion(.unknown(error: "No Result")); return }
            let user = result.user
            self.user = User(id: user.uid, email: user.email ?? "")
            
            user.sendEmailVerification() { error in
                print(error?.localizedDescription ?? "")
                completion(.signedUp)
            }
        }
    }
    
    func signInUser(with email: String, password: String, completion: @escaping (AuthStatus) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                if let errorCode = AuthErrorCode(rawValue: error._code) {
                    switch errorCode {
                    case .invalidCredential:
                        completion(.invalidCredential)
                    case .invalidEmail:
                        completion(.invalidEmail)
                    case .networkError:
                        completion(.networkError)
                    case .missingEmail:
                        completion(.missingEmail)
                    default:
                        completion(.unknown(error: error.localizedDescription))
                    }
                }
            } else {
                completion(.signedIn)
            }
        }
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
