
import Foundation
import Firebase
import CodableFirebase

enum Team: Int, Codable {
    case mystic
    case valor
    case instinct
    
    var description: String {
        switch self {
            case .mystic: return "Mystic"
            case .valor: return "Valor"
            case .instinct: return "Instinct"
        }
    }
    
    var color: UIColor? {
        get {
            switch self {
            case .mystic:
                return .blue
            case .valor:
                return .red
            case .instinct:
                return .orange
            }
        }
    }
    
    var image: UIImage {
        get {
            switch self {
            case .mystic:
                return UIImage(named: "mystic")!
            case .valor:
                return UIImage(named: "valor")!
            case .instinct:
                return UIImage(named: "instinct")!
            }
        }
    }
}

class User: FirebaseCodable, Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String!
    var email: String?
    var trainerName: String?
    var notificationToken: String?
    var level: Int?
    var team: Team?
    var teamName: String? {
        get {
            if let team = team {
                switch team {
                case .mystic:
                    return "Mystic"
                case .valor:
                    return "Valor"
                case .instinct:
                    return "Instinct"
                }
            }
            return nil
        }
    }
    
    init(id: String,
         email: String,
         trainerName: String,
         team: Team,
         level: Int,
         notificationToken: String? = nil) {
        
        self.id = id
        self.email = email
        self.trainerName = trainerName
        self.team = team
        self.level = level
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
    
    func updateTeam(_ team: Team) {
        guard self.team != team else { return }
        self.team = team
        let users = Database.database().reference(withPath: "users")
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let data = ["team" : team.rawValue]
        users.child(userId).updateChildValues(data)
        print("✅👨🏻 Did update team")
    }
    
    func updateTrainerLevel(_ level: Int) {
        guard self.level != level else { return }
        self.level = level
        let users = Database.database().reference(withPath: "users")
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let data = ["level" : level]
        users.child(userId).updateChildValues(data)
        print("✅👨🏻 Did update level")
    }
    
    func updateNotificationToken(_ token: String) {
        notificationToken = token
    }
    
    class func load(completion: @escaping (User?) -> ()) {
        let usersRef = Database.database().reference(withPath: "users")
        guard let userId = Auth.auth().currentUser?.uid else { return }

        usersRef.child(userId).observeSingleEvent(of: .value) { snapshot in
            guard let user: User = decode(from: snapshot) else { return }
            completion(user)
        }
    }
    
    class func signUp(with email: String,
                      password: String,
                      trainerName: String,
                      team: Team,
                      level: Int,
                      completion: @escaping (AuthStatus) -> ()) {
        
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
            let firebaseUser = result.user

            firebaseUser.sendEmailVerification() { error in
                print(error?.localizedDescription ?? "")
                completion(.signedUp)
            }
            
            let user = User(id: firebaseUser.uid,
                            email: firebaseUser.email!,
                            trainerName: trainerName,
                            team: team,
                            level: level)
            
            let data = try! FirebaseEncoder().encode(user)
            let ref = Database.database().reference(withPath: "users").child(firebaseUser.uid)
            ref.setValue(data)
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
