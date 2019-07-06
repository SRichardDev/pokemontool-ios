
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

struct PublicUserData: FirebaseCodable {
    var id: String!
    var trainerName: String?
    var team: Team?
    var level: Int?
    var trainerCode: String?
    
    init(trainerName: String, team: Team, level: Int, trainerCode: String) {
        self.id = ""
        self.trainerName = trainerName
        self.team = team
        self.level = level
        self.trainerCode = trainerCode
    }
}

class User: FirebaseCodable, Equatable {
    
    typealias PokestopId = String
    typealias ArenaId = String

    var usersRef: DatabaseReference {
        get {
            return Database.database().reference(withPath: DatabaseKeys.users)
        }
    }
    
    var id: String!
    var email: String
    var platform: String?
    var publicData: PublicUserData?
    var notificationToken: String?
    var submittedPokestops: [PokestopId: String]?
    var submittedArenas: [ArenaId: String]?
    var goldArenas: [ArenaId: String]?
    var submittedRaids: Int?
    var submittedQuests: Int?
    var subscribedGeohashPokestops: [String: String]?
    var subscribedGeohashArenas: [String: String]?
    var isPushActive: Bool? = true

    var teamName: String? {
        get {
            return publicData?.team?.description
        }
    }
    
    init(id: String,
         email: String,
         publicData: PublicUserData,
         submittedPokestops: [PokestopId: String]? = nil,
         submittedArenas: [ArenaId: String]? = nil,
         goldArenas: [ArenaId: String]? = nil,
         submittedRaids: Int? = nil,
         submittedQuests: Int? = nil,
         subscribedGeohashPokestops: [String: String]? = nil,
         subscribedGeohashArenas: [String: String]? = nil,
         notificationToken: String? = nil,
         isPushActive: Bool = true) {
        
        self.id = id
        self.email = email
        self.publicData = publicData
        self.submittedPokestops = submittedPokestops
        self.submittedArenas = submittedArenas
        self.goldArenas = goldArenas
        self.submittedRaids = submittedRaids
        self.submittedQuests = submittedQuests
        self.subscribedGeohashPokestops = subscribedGeohashPokestops
        self.subscribedGeohashArenas = subscribedGeohashArenas
        self.notificationToken = notificationToken
        self.isPushActive = isPushActive
    }
    
    func updateTrainerName(_ name: String) {
        guard publicData?.trainerName != name else { return }
        publicData?.trainerName = name
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let data = [DatabaseKeys.trainerName : name]
        usersRef.child(userId).child(DatabaseKeys.publicUserData).updateChildValues(data)
        print("✅👨🏻 Did update trainer name to database")
    }
    
    func updateTeam(_ team: Team) {
        guard publicData?.team != team else { return }
        publicData?.team = team
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let data = [DatabaseKeys.team : team.rawValue]
        usersRef.child(userId).child(DatabaseKeys.publicUserData).updateChildValues(data)
        print("✅👨🏻 Did update team")
    }
    
    func updateTrainerLevel(_ level: Int) {
        guard publicData?.level != level else { return }
        publicData?.level = level
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let data = [DatabaseKeys.level : level]
        usersRef.child(userId).child(DatabaseKeys.publicUserData).updateChildValues(data)
        print("✅👨🏻 Did update level")
    }
    
    func updateTrainerCode(_ code: String) {
        guard publicData?.trainerCode != code else { return }
        publicData?.trainerCode = code
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let data = [DatabaseKeys.trainerCode : code]
        usersRef.child(userId).child(DatabaseKeys.publicUserData).updateChildValues(data)
        print("✅👨🏻 Did update trainer code")
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
            .child(geohash)
            .removeValue()
    }
    
    func activatePush(_ activated: Bool) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let data = [DatabaseKeys.pushActive : activated]
        usersRef
            .child(userId)
            .updateChildValues(data)
    }
    
    class func load(completion: @escaping (User?) -> ()) {
        let usersRef = Database.database().reference(withPath:   DatabaseKeys.users)
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
            
            let publicUserData = PublicUserData(trainerName: trainerName, team: team, level: level, trainerCode: "")
            
            let user = User(id: firebaseUser.uid,
                            email: firebaseUser.email!,
                            publicData: publicUserData,
                            isPushActive: true)
            
            let data = try! FirebaseEncoder().encode(user)
            let ref = Database.database().reference(withPath: DatabaseKeys.users).child(firebaseUser.uid)
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
