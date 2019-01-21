
import Foundation
import Firebase

protocol FirebaseDelegate {
    func didUpdateQuests()
}

protocol FirebaseStatusPresentable {
    var firebaseConnector: FirebaseConnector! { get set }
}

class FirebaseConnector {
    
    private var database: DatabaseReference!
    var pokestops = [Pokestop]()
    var delegate: FirebaseDelegate?
    
    var isSignedIn: Bool {
        return Auth.auth().currentUser?.uid != nil ? true : false
    }
    
    init() {
        database = Database.database().reference(withPath: "pokestops")
    }
    
    func savePokestop(_ pokestop: Pokestop) {
        let data = ["name"      : pokestop.name,
                    "latitude"  : pokestop.latitude.string,
                    "longitude" : pokestop.longitude.string]
        
        saveToDatabase(data: data, geohash: pokestop.geohash)
    }
    
    func saveQuest(quest: Quest, for pokestop: Pokestop) {
        guard let pokestopID = pokestop.id else {return}
        let data = ["quest" : ["name" : quest.name,
                               "reward" : quest.reward,
                               "submitter" : quest.submitter]]
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
            database.child(geohash).child(id).setValue(data)
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
                    let name = values["name"] as! String
                    let latitude = Double(values["latitude"] as! String)!
                    let longitude = Double(values["longitude"] as! String)!
                    
//                    let quest = values["quest"] as! String
//                    let reward = values["reward"] as! String
//                    let submitter = values["submitter"] as! String
                    
                    let pokestop = Pokestop(name: name,
                                            latitude: latitude,
                                            longitude: longitude,
                                            id: child.key,
                                            quest: nil)
                    
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
