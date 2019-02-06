
import Foundation
import Firebase

class User: Codable {
    private(set) var id: String
    private(set) var email: String
    private(set) var trainerName: String?
    private(set) var notificationToken: String?
    
    init(id: String, email: String, trainerName: String? = nil, notificationToken: String? = nil) {
        self.id = id
        self.email = email
        self.trainerName = trainerName
        self.notificationToken = notificationToken
    }
    
    func updateTrainerName(_ name: String) {
        guard trainerName != name else { return }
        trainerName = name
        let users = Database.database().reference(withPath: "users")
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let data = ["trainerName" : name]
        users.child(userId).updateChildValues(data)
        print("✅👨🏻 Did update trainer name to database")
    }
    
    func updateNotificationToken(_ token: String) {
        notificationToken = token
    }
    
    class func load(completion: @escaping (User?) -> ()) {
        let users = Database.database().reference(withPath: "users")
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let email = Auth.auth().currentUser?.email else { return }
        users.child(userId).observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String : String] {
                let name = value["trainerName"]
                let notificationToken = value["notificationToken"]
                let user = User(id: userId, email: email, trainerName: name, notificationToken: notificationToken)
                print("✅👨🏻 Did load user")
                completion(user)
            }
        }
    }
    
    class func signUp(with email: String, password: String, completion: @escaping (AuthStatus) -> ()) {
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

            user.sendEmailVerification() { error in
                print(error?.localizedDescription ?? "")
                completion(.signedUp)
            }
        }
    }
    
    class func signIn(with email: String, password: String, completion: @escaping (AuthStatus) -> ()) {
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
