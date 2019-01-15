
import Foundation
import Firebase

struct Quest {
    let name: String
    let reward: String
    let latitude: Double
    let longitude: Double
    let submitter: String
    //upvotes
    //downvotes
}

class FirebaseConnector {
    
    private var database: DatabaseReference!
    
    init() {
        database = Database.database().reference()
        
//        let quest = Quest(name: "Foo", reward: "bar", latitude: 48.41235, longitude: 11.23564, submitter: "Developer")
//        saveQuest(quest)
        let _ = loadQuests()
    }
    
    func saveQuest(_ quest: Quest) {
        let geohash = "\(Geohash.encode(latitude: quest.latitude, longitude: quest.longitude))"
        
        let data = ["name"      : quest.name,
                    "reward"    : quest.reward,
                    "latitude"  : "\(quest.latitude)",
                    "longitude" : "\(quest.longitude)",
                    "submitter" : "\(quest.submitter)"]
        
        database.child("quests").child(geohash).childByAutoId().setValue(data)
    }
    
    func loadQuests() -> [Quest] {
        database.observe(.childAdded, with: { snapshot in
            
//            snapshot.children.forEach { print($0) }
            
            
//            print(snapshot.key)
//            guard let dict = snapshot.value as? [String : Any] else { return }
            print(snapshot.value(forKey: "quests") ?? "")
            
            
//            print(dict)
//            print(snapshot.childSnapshot(forPath: "quests"))
        })
        return [Quest(name: "Foo", reward: "bar", latitude: 48.41235, longitude: 11.23564, submitter: "Developer")]
    }
}
