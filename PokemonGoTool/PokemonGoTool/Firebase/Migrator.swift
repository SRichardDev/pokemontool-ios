
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
            firebaseConnector.unsubscribeFormTopic(Topics.incidents, topicType: .topics)

            firebaseConnector.subscribeToTopic(Topics.raids, topicType: .topics)
            firebaseConnector.subscribeToTopic(Topics.quests, topicType: .topics)
            firebaseConnector.subscribeToTopic(Topics.incidents, topicType: .topics)

            firebaseConnector.subscribeToTopic("level-1", topicType: .topics)
            firebaseConnector.subscribeToTopic("level-2", topicType: .topics)
            firebaseConnector.subscribeToTopic("level-3", topicType: .topics)
            firebaseConnector.subscribeToTopic("level-4", topicType: .topics)
            firebaseConnector.subscribeToTopic("level-5", topicType: .topics)
            firebaseConnector.subscribeToTopic("iOS", topicType: .topics)

            let topicSubscriptionManager = TopicSubscriptionManager()
            
            if let subscribedGeohashes = user.subscribedGeohashArenas?.keys {
                for geohash in subscribedGeohashes {
                    user.removeGeohashForPushSubsription(for: .arena, geohash: geohash)
                    user.removeGeohashForPushSubsription(for: .pokestop, geohash: geohash)
                    guard let user = firebaseConnector.user else { continue }
                    topicSubscriptionManager.subscribeToTopic(for: user, in: geohash, for: .geohash)
                }
            }
        }
    }
}
