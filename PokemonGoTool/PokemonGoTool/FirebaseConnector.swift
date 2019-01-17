
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

class FirebaseConnector {
    
    private var database: DatabaseReference!
    var quests = [Quest]()
    var delegate: FirebaseDelegate?
    
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
        
        database.child(geohash).childByAutoId().setValue(data)
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
}
