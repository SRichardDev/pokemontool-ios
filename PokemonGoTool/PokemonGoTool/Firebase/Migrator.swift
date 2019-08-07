
import Firebase

class Migrator {
    
    private let firebaseConnector: FirebaseConnector
    private let userDefaults = UserDefaults.standard
    
    @discardableResult
    init(firebaseConnector: FirebaseConnector) {
        self.firebaseConnector = firebaseConnector
        migrateToBuild23()
    }
    
    private func migrateToBuild23() {
        guard let user = firebaseConnector.user else { return }
        
        if userDefaults.integer(forKey: "buildNumber") < 23 {
            
            userDefaults.set(23, forKey: "buildNumber")
            
            if let topics = user.topics {
                for topic in topics.keys {
                    firebaseConnector.unsubscribeFormTopic(topic, topicType: .topics)
                }
            }
            
            firebaseConnector.unsubscribeFormTopic("arena", topicType: .topics)
            firebaseConnector.unsubscribeFormTopic("pokestop", topicType: .topics)

            firebaseConnector.subscribeToTopic(Topics.iOS, topicType: .topics)
            firebaseConnector.subscribeToTopic(Topics.quests, topicType: .topics)
            firebaseConnector.subscribeToTopic(Topics.raids, topicType: .topics)
            firebaseConnector.subscribeToTopic(Topics.incidents, topicType: .topics)
            (1...5).forEach { firebaseConnector.subscribeToTopic(Topics.level + "\($0)", topicType: .topics) }

            let topicSubscriptionManager = TopicSubscriptionManager()
            
            if let subscribedGeohashes = user.subscribedGeohashArenas?.keys {
                for geohash in subscribedGeohashes {
                    user.removeGeohashForPushSubsription(for: .arena, geohash: geohash)
                    user.removeGeohashForPushSubsription(for: .pokestop, geohash: geohash)
                    guard let user = firebaseConnector.user else { continue }
                    topicSubscriptionManager.subscribeToTopic(for: user, in: geohash, for: .geohash)
                }
            }
            
            let usersRef = Database.database().reference(withPath: DatabaseKeys.users)
            
            usersRef
                .child(user.id)
                .child("isPushActive")
                .removeValue()
        }
    }
}
