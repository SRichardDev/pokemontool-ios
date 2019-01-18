
import Foundation
import Firebase

struct Quest {
    let pokestop: String
    let name: String
    let reward: String
    let latitude: Double
    let longitude: Double
    let submitter: String
    let id: String?
}

protocol FirebaseDelegate {
    func didUpdateQuests()
}

protocol FirebaseStatusPresentable {
    var firebaseConnector: FirebaseConnector! { get set }
}

class FirebaseConnector {
    
    private var database: DatabaseReference!
    var quests = [Quest]()
    var delegate: FirebaseDelegate?
    
    var isSignedIn: Bool {
        return Auth.auth().currentUser?.uid != nil ? true : false
    }
    
    init() {
        database = Database.database().reference(withPath: "quests")
    }
    
    func saveQuest(_ quest: Quest) {
        let geohash = "\(Geohash.encode(latitude: quest.latitude, longitude: quest.longitude))"
        
        let data = ["pokestop"  : quest.pokestop,
                    "name"      : quest.name,
                    "reward"    : quest.reward,
                    "latitude"  : "\(quest.latitude)",
                    "longitude" : "\(quest.longitude)",
                    "submitter" : quest.submitter]
        
        
        if Auth.auth().currentUser != nil {
            database.child(geohash).childByAutoId().setValue(data)
            print("✅ Did write quest to database")
        } else {
            print("❌ Not authenticated, can not write to database")
        }
    }
    
    func loadQuests(for geoHash: String) {
        guard geoHash != "" else { return }
        quests.removeAll()
        database.child(geoHash).observe(.value, with: { snapshot in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for child in result {
                    let values = child.value as! [String: Any]
                    let pokestop = values["pokestop"] as! String
                    let name = values["name"] as! String
                    let reward = values["reward"] as! String
                    let latitude = Double(values["latitude"] as! String)!
                    let longitude = Double(values["longitude"] as! String)!
                    let submitter = values["submitter"] as! String
                    let quest = Quest(pokestop: pokestop,
                                      name: name,
                                      reward: reward,
                                      latitude: latitude,
                                      longitude: longitude,
                                      submitter: submitter,
                                      id: child.key)
                    
                    var questAlreadySaved = false
                    
                    self.quests.forEach { savedQuest in
                        if quest.id == savedQuest.id {
                            questAlreadySaved = true
                        }
                    }
                    
                    if !questAlreadySaved {
                        self.quests.append(quest)
                    }
                }
                self.delegate?.didUpdateQuests()
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
            
            if result != nil {
                result?.user.sendEmailVerification() { error in
                    completion(.signedUp)
                }
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
