
import Firebase
import FirebaseMessaging

enum TopicType: CustomStringConvertible {
    
    case topics
    case geohash
    case raidMeetups
    
    var description: String {
        switch self {
        case .topics: return DatabaseKeys.topics
        case .geohash: return DatabaseKeys.subscribedGeohashes
        case .raidMeetups: return DatabaseKeys.subscribedRaidMeetups
        }
    }
}

class TopicSubscriptionManager {
    
    private let usersRef = Database.database().reference(withPath: DatabaseKeys.users)
        
    func subscribeToTopic(for user: User, in topic: String, for type: TopicType) {

        Messaging.messaging().subscribe(toTopic: topic) { error in
            if let error = error {
                print(error)
            } else {
                let data = [topic : ""]
                self.usersRef
                    .child(user.id)
                    .child(type.description)
                    .updateChildValues(data)
                print("Subscribed to \(topic) topic")
            }
        }
    }
    
    func unsubscribeFromTopic(for user: User, in topic: String, for type: TopicType) {

        Messaging.messaging().unsubscribe(fromTopic: topic) { error in
            if let error = error {
                print(error)
            } else {
                self.usersRef
                    .child(user.id)
                    .child(type.description)
                    .child(topic)
                    .removeValue()
                print("Unsubscribed from \(topic) topic")
            }
        }
    }
}
