
import UIKit
import Firebase
import UserNotifications
import Firebase
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?

    lazy var appModule: AppModule = {
        return AppModule()
    }()
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = appModule.tabBarController
        window?.makeKeyAndVisible()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                
                guard let userID = Auth.auth().currentUser?.uid else {return}
                let database = Database.database().reference(withPath: "users/\(userID)")
                let data = ["notificationToken" : fcmToken]
                database.setValue(data)

//                self.instanceIDTokenMessage.text  = "Remote InstanceID token: \(result.token)"
            }
        }
        
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        
        Messaging.messaging().subscribe(toTopic: "quests") { error in
            print("Subscribed to quests topic")
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}
}

