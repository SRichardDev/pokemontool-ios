
import Foundation
import Firebase

class User {
    private(set) var id: String
    private(set) var email: String
    private(set) var trainerName: String?
    private(set) var notificationToken: String?
    
    init(id: String, email: String, trainerName: String? = nil) {
        self.id = id
        self.email = email
        self.trainerName = trainerName
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
    
    class func loadUser(completion: @escaping (User?) -> ()) {
        let users = Database.database().reference(withPath: "users")
        guard let userId = Auth.auth().currentUser?.uid else { return }
        users.child(userId).observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                let name = value["trainerName"] as? String ?? ""
                let email = value["email"] as? String ?? ""
                let user = User(id: userId, email: email, trainerName: name)
                print("✅👨🏻 Did load user")
                completion(user)
            }
        }
    }
}
