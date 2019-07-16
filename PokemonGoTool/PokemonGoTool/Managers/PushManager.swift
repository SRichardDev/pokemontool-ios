
import Foundation
import UserNotifications
import MapKit
import Firebase
import FirebaseMessaging

struct PushNotification {
    let title: String
    let message: String
    let coordinate: CLLocationCoordinate2D
}

protocol PushManagerDelegate: class {
    func didReceivePush()
}

class PushManager {
    
    static let shared = PushManager()
    weak var delegate: PushManagerDelegate?
    var latestPushNotification: PushNotification?
    
    private init() {}
    
    func registerForPush() {
        guard let userID = Auth.auth().currentUser?.uid else { print("🔥❌ No current user. Skipping push registration"); return }
        
        UNUserNotificationCenter.current().delegate = UIApplication.shared.delegate as? UNUserNotificationCenterDelegate
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions,
                                                                completionHandler: {_, _ in })
        UIApplication.shared.registerForRemoteNotifications()
        
        if let token = Messaging.messaging().fcmToken {
            let database = Database.database().reference(withPath: "users/\(userID)")
            let data = ["notificationToken" : token,
                        "platform" : "iOS"]
            database.updateChildValues(data)
            print("🔥📲 Push token saved to user")
        }
        print("🔥📲 Push registration completed")
    }
    
    func parsePushNotification(response: UNNotificationResponse) {
        let title = response.notification.request.content.title
        let message = response.notification.request.content.body
        let userInfo = response.notification.request.content.userInfo
        guard let latitude = userInfo["latitude"] as? String else {return}
        guard let longitude = userInfo["longitude"] as? String else {return}
        
        let coordiante = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude.double),
                                                longitude:CLLocationDegrees(longitude.double))

        latestPushNotification = PushNotification(title: title, message: message, coordinate: coordiante)
        delegate?.didReceivePush()
    }
}
