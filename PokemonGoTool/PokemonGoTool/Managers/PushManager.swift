
import Foundation
import UserNotifications
import MapKit
import Firebase
import FirebaseMessaging

protocol PushNotification {
}

struct PushNotificationIdentifiers {
    static let onCreateRaid = "onCreateRaid"
    static let onUpdateRaidMeetup = "onUpdateRaidMeetup"
}

struct ArenaPushNotification: PushNotification {
    var coordinate: CLLocationCoordinate2D
    var arenaId: String
    var geohash: String
}


protocol PushManagerDelegate: class {
    func didReceivePush(_ push: PushNotification)
}

class PushManager {
    
    static let shared = PushManager()
    weak var delegate: PushManagerDelegate?
    var latestPushNotification: PushNotification?
    
    private init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
    
    @objc
    func willResignActive() {
        if !AppSettings.isPushActive {
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = "Push Nachrichten deaktiviert"
            content.body = "Du bekommst ab jetzt keine Nachrichten mehr"
            content.sound = UNNotificationSound.default
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            center.add(request)
        }
    }
    
    func registerForPush() {
        guard let userID = Auth.auth().currentUser?.uid else { print("🔥❌ No current user. Skipping push registration"); return }
        
        UNUserNotificationCenter.current().delegate = UIApplication.shared.delegate as? UNUserNotificationCenterDelegate
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions,
                                                                completionHandler: {_, _ in })
        UIApplication.shared.registerForRemoteNotifications()
        
        if let token = Messaging.messaging().fcmToken {
            let database = Database.database().reference(withPath: "users/\(userID)")
            let data = [DatabaseKeys.notificationToken : token,
                        DatabaseKeys.platform : "iOS"]
            database.updateChildValues(data)
            print("🔥📲 Push token saved to user")
        }
        print("🔥📲 Push registration completed")
    }
    
    func parsePushNotification(response: UNNotificationResponse) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let identifier = userInfo["identifier"] as? String {
            if identifier == PushNotificationIdentifiers.onUpdateRaidMeetup {
                parseOnUpdateRaidMeetup(with: userInfo)
            }
            
            if identifier == PushNotificationIdentifiers.onCreateRaid {
                parseOnUpdateRaidMeetup(with: userInfo)
            }
        }
        
//        guard let latitude = userInfo["latitude"] as? String else { return }
//        guard let longitude = userInfo["longitude"] as? String else { return }
//
//        let coordiante = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude.double),
//                                                longitude:CLLocationDegrees(longitude.double))

//        latestPushNotification = PushNotification(title: title, message: message, coordinate: coordiante)
//        delegate?.didReceivePush()
    }
    
    private func parseOnUpdateRaidMeetup(with userInfo: [AnyHashable : Any]) {
        guard let arenaId = userInfo["arena"] as? String else { return }
        guard let geohash = userInfo["geohash"] as? String else { return }
        guard let latitude = userInfo["latitude"] as? String else { return }
        guard let longitude = userInfo["longitude"] as? String else { return }

        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude.double),
                                                longitude:CLLocationDegrees(longitude.double))

        let push = ArenaPushNotification(coordinate: coordinate,
                                         arenaId: arenaId,
                                         geohash: geohash)
        latestPushNotification = push
        delegate?.didReceivePush(push)
    }
    
    private func parseOnCreateRaid(with userInfo: [AnyHashable : Any]) {
        guard let arenaId = userInfo["arena"] as? String else { return }
        guard let geohash = userInfo["geohash"] as? String else { return }
        guard let latitude = userInfo["latitude"] as? String else { return }
        guard let longitude = userInfo["longitude"] as? String else { return }

        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude.double),
                                                longitude:CLLocationDegrees(longitude.double))

        let push = ArenaPushNotification(coordinate: coordinate,
                                         arenaId: arenaId,
                                         geohash: geohash)
        
        latestPushNotification = push
        delegate?.didReceivePush(push)
    }
}
