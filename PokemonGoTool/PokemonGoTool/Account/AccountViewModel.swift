
import UIKit

class AccountViewModel {
    
    private let firebaseConnector: FirebaseConnector
    
    var accountMedalViewModel: AccountMedalViewModel {get{return AccountMedalViewModel(firebaseConnector: firebaseConnector)}}
    var trainerName: String {get{return firebaseConnector.user?.publicData?.trainerName ?? ""}}
    var currentTeam: Team? {get{return firebaseConnector.user?.publicData?.team}}
    var currentLevel: Int {get{return (firebaseConnector.user?.publicData?.level ?? 0)}}
    var trainerCode: String {get{return firebaseConnector.user?.publicData?.trainerCode ?? ""}}
    var isLoggedIn: Bool {get{return firebaseConnector.isSignedIn}}
    var isPushActivated: Bool {get{return firebaseConnector.user?.isPushActive ?? false}}
    var isQuestTopicSubscribed: Bool {get{return firebaseConnector.user?.topics?.contains { $0.key == "quests"} ?? false}}
    var isRaidTopicSubscribed: Bool {get{return firebaseConnector.user?.topics?.contains { $0.key == "raids"} ?? false}}
    var isLevel5TopicSubscribed: Bool {get{return firebaseConnector.user?.topics?.contains { $0.key == "level-5"} ?? false}}
    var isLevel4TopicSubscribed: Bool {get{return firebaseConnector.user?.topics?.contains { $0.key == "level-4"} ?? false}}
    var isLevel3TopicSubscribed: Bool {get{return firebaseConnector.user?.topics?.contains { $0.key == "level-3"} ?? false}}
    var isLevel2TopicSubscribed: Bool {get{return firebaseConnector.user?.topics?.contains { $0.key == "level-2"} ?? false}}
    var isLevel1TopicSubscribed: Bool {get{return firebaseConnector.user?.topics?.contains { $0.key == "level-1"} ?? false}}

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
    }
    
    func subscribeForQuestsPush(_ subscribed: Bool) {
        if subscribed {
            firebaseConnector.subscribeToTopic(Topics.quests)
        } else {
            firebaseConnector.unsubscribeFormTopic(Topics.quests)
        }
    }
    
    func subscribeForRaidsPush(_ subscribed: Bool) {
        if subscribed {
            firebaseConnector.subscribeToTopic(Topics.raids)
        } else {
            firebaseConnector.unsubscribeFormTopic(Topics.raids)
        }
    }
    
    func subscribeForRaidLevelPush(_ subscribed: Bool, level: Int) {
        if subscribed {
            firebaseConnector.subscribeToTopic(Topics.level + "\(level)")
        } else {
            firebaseConnector.unsubscribeFormTopic(Topics.level + "\(level)")
        }
    }
}
