
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
    
    var color: UIColor {
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
    
    typealias PokestopId = String
    typealias ArenaId = String

    var usersRef: DatabaseReference {
        get {
            return Database.database().reference(withPath: "users")
        }
    }
    
    var id: String!
    var email: String?
    var trainerName: String?
    var notificationToken: String?
    var level: Int?
    var team: Team?
    var submittedPokestops: [PokestopId: String]?
    var submittedArenas: [ArenaId: String]?
    var goldArenas: [ArenaId: String]?
    var submittedRaids: Int?
    var submittedQuests: Int?
    var subscribedGeohashPokestops: [String: String]?
    var subscribedGeohashArenas: [String: String]?

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
         submittedPokestops: [PokestopId: String]? = nil,
         submittedArenas: [ArenaId: String]? = nil,
         goldArenas: [ArenaId: String]? = nil,
         submittedRaids: Int? = nil,
         submittedQuests: Int? = nil,
         subscribedGeohashPokestops: [String: String]? = nil,
         subscribedGeohashArenas: [String: String]? = nil,
         notificationToken: String? = nil) {
        
        self.id = id
        self.email = email
        self.trainerName = trainerName
        self.team = team
        self.level = level
        self.submittedPokestops = submittedPokestops
        self.submittedArenas = submittedArenas
        self.goldArenas = goldArenas
        self.submittedRaids = submittedRaids
        self.submittedQuests = submittedQuests
        self.subscribedGeohashPokestops = subscribedGeohashPokestops
        self.subscribedGeohashArenas = subscribedGeohashArenas
        self.notificationToken = notificationToken
    }
    
    func updateTrainerName(_ name: String) {
        guard trainerName != name else { return }
        trainerName = name
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let data = [DatabaseKeys.trainerName : name]
        usersRef.child(userId).updateChildValues(data)
        print("✅👨🏻 Did update trainer name to database")
    }
    
    func updateTeam(_ team: Team) {
        guard self.team != team else { return }
        self.team = team
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let data = [DatabaseKeys.team : team.rawValue]
        usersRef.child(userId).updateChildValues(data)
        print("✅👨🏻 Did update team")
    }
    
    func updateTrainerLevel(_ level: Int) {
        guard self.level != level else { return }
        self.level = level
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let data = [DatabaseKeys.level : level]
        usersRef.child(userId).updateChildValues(data)
        print("✅👨🏻 Did update level")
    }
    
    func updateNotificationToken(_ token: String) {
        notificationToken = token
    }
    
    func saveSubmittedPokestopId(_ id: PokestopId, for geohash: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let data = [id : geohash]
        usersRef
            .child(userId)
            .child(DatabaseKeys.submittedPokestops)
            .updateChildValues(data)
        print("✅👨🏻 Did add PokestopId to user")
    }
    
    func saveSubmittedArena(_ id: ArenaId, for geohash: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let data = [id : geohash]
        usersRef
            .child(userId)
            .child(DatabaseKeys.submittedArenas)
            .updateChildValues(data)
        print("✅👨🏻 Did add ArenaId to user")
    }
    
    func updateSubmittedQuestCount() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let data = [DatabaseKeys.submittedQuests : (submittedQuests ?? 0) + 1]
        usersRef
            .child(userId)
            .updateChildValues(data)
        print("✅👨🏻 Did update submitted quest count to user")
    }
    
    func updateSubmittedRaidCount() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let data = [DatabaseKeys.submittedRaids : (submittedRaids ?? 0) + 1]
        usersRef
            .child(userId)
            .updateChildValues(data)
        print("✅👨🏻 Did update submitted raid count to user")
    }
    
    func addGoldArena(_ id: ArenaId, for geohash: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let data = [id : geohash]
        usersRef
            .child(userId)
            .child(DatabaseKeys.goldArenas)
            .updateChildValues(data)
    }
    
    func removeGoldArena(_ id: ArenaId) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        usersRef
            .child(userId)
            .child(DatabaseKeys.goldArenas)
            .child(id)
            .removeValue()
    }
    
    func addGeohashForPushSubscription(for poiType: PoiType, geohash: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let data = [geohash : ""]
        usersRef
            .child(userId)
            .child(poiType.databaseKey)
            .updateChildValues(data)
    }
    
    func removeGeohashForPushSubsription(for poiType: PoiType, geohash: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        usersRef
            .child(userId)
            .child(poiType.databaseKey)
            .removeValue()
    }
    
    class func load(completion: @escaping (User?) -> ()) {
        let usersRef = Database.database().reference(withPath: "users")
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        usersRef.child(userId).observe(.value) { snapshot in
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
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
