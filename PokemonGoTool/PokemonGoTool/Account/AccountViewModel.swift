
import UIKit

class AccountViewModel {
    
    private let firebaseConnector: FirebaseConnector
    
    var accountMedalViewModel: AccountMedalViewModel { return AccountMedalViewModel(firebaseConnector: firebaseConnector)}
    var trainerName: String { return firebaseConnector.user?.publicData?.trainerName ?? ""}
    var currentTeam: Team? { return firebaseConnector.user?.publicData?.team}
    var currentLevel: Int { return (firebaseConnector.user?.publicData?.level ?? 0)}
    var trainerCode: String { return firebaseConnector.user?.publicData?.trainerCode ?? ""}
    var isLoggedIn: Bool { return firebaseConnector.isSignedIn}
    var isPushActivated: Bool { return firebaseConnector.user?.isPushActive ?? false}
    var isQuestTopicSubscribed: Bool { return firebaseConnector.user?.topics?.contains { $0.key == "quests"} ?? false}
    var isRaidTopicSubscribed: Bool { return firebaseConnector.user?.topics?.contains { $0.key == "raids"} ?? false}
    var isLevel5TopicSubscribed: Bool { return firebaseConnector.user?.topics?.contains { $0.key == "level-5"} ?? false}
    var isLevel4TopicSubscribed: Bool { return firebaseConnector.user?.topics?.contains { $0.key == "level-4"} ?? false}
    var isLevel3TopicSubscribed: Bool { return firebaseConnector.user?.topics?.contains { $0.key == "level-3"} ?? false}
    var isLevel2TopicSubscribed: Bool { return firebaseConnector.user?.topics?.contains { $0.key == "level-2"} ?? false}
    var isLevel1TopicSubscribed: Bool { return firebaseConnector.user?.topics?.contains { $0.key == "level-1"} ?? false}

    init(firebaseConnector: FirebaseConnector) {
        self.firebaseConnector = firebaseConnector
    }
    
    func updateTrainerName(_ name: String) {
        guard name != "" else { return }
        firebaseConnector.user?.updateTrainerName(name)
    }
    
    func updateTeam(_ team: Team) {
        firebaseConnector.user?.updateTeam(team)
    }
    
    func updateLevel(_ level: Int) {
        firebaseConnector.user?.updateTrainerLevel(level)
    }
    
    func updateTrainerCode(_ code: String) {
        guard code != "" else { return }
        firebaseConnector.user?.updateTrainerCode(code)
    }
    
    func pushActivatedChanged(_ activated: Bool) {
        firebaseConnector.user?.activatePush(activated)
        
        if activated {
            firebaseConnector.subscribeToTopic(Topics.iOS, topicType: .topics)
        } else {
            firebaseConnector.unsubscribeFormTopic(Topics.iOS, topicType: .topics)
        }
    }
    
    func subscribeForQuestsPush(_ subscribed: Bool) {
        if subscribed {
            firebaseConnector.subscribeToTopic(Topics.quests, topicType: .topics)
        } else {
            firebaseConnector.unsubscribeFormTopic(Topics.quests, topicType: .topics)
        }
    }
    
    func subscribeForRaidsPush(_ subscribed: Bool) {
        if subscribed {
            firebaseConnector.subscribeToTopic(Topics.raids, topicType: .topics)
        } else {
            firebaseConnector.unsubscribeFormTopic(Topics.raids, topicType: .topics)
        }
    }
    
    func subscribeForRaidLevelPush(_ subscribed: Bool, level: Int) {
        if subscribed {
            firebaseConnector.subscribeToTopic(Topics.level + "\(level)", topicType: .topics)
        } else {
            firebaseConnector.unsubscribeFormTopic(Topics.level + "\(level)", topicType: .topics)
        }
    }
}
