
import UIKit
import Firebase
import UserNotifications
import Firebase
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    var coordinator: MainCoordinator?
    
    lazy var appModule: AppModule = {
        return AppModule()
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setupReachability()
        FirebaseApp.configure()
        UIApplication.shared.registerForRemoteNotifications()
        Database.database().isPersistenceEnabled = true
        PushManager.shared.registerForPush()
        Messaging.messaging().delegate = self
        window = UIWindow(frame: UIScreen.main.bounds)
        coordinator = MainCoordinator(appModule: appModule, window: window!)
        Theming.applySelectedPersistedTheme()
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging,
                   didReceive remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let application = UIApplication.shared

        if application.applicationState == .active {
            print("user tapped the notification bar when the app is in foreground")
        }
        
        if application.applicationState == .inactive {
            print("user tapped the notification bar when the app is in background")
        }
        PushManager.shared.parsePushNotification(response: response)
        completionHandler()
    }

    func messaging(_ messaging: Messaging,
                   didReceiveRegistrationToken fcmToken: String) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("??????? Error fetching remote instance ID: \(error)")
            } else {
                guard let userID = Auth.auth().currentUser?.uid else {return}
                print("??????? Firebase registration token: \(fcmToken)")
                let database = Database.database().reference(withPath: "users/\(userID)")
                let data = [DatabaseKeys.notificationToken : fcmToken,
                            DatabaseKeys.platform : "iOS"]
                database.updateChildValues(data)
            }
        }
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = -1
    }
    
    func setupReachability() {
        do {
            try Network.reachability = Reachability(hostname: "www.google.com")
        }
        catch {
            switch error as? Network.Error {
            case let .failedToCreateWith(hostname)?:
                print("Network error:\nFailed to create reachability object With host named:", hostname)
            case let .failedToInitializeWith(address)?:
                print("Network error:\nFailed to initialize reachability object With address:", address)
            case .failedToSetCallout?:
                print("Network error:\nFailed to set callout")
            case .failedToSetDispatchQueue?:
                print("Network error:\nFailed to set DispatchQueue")
            case .none:
                print(error)
            }
        }
    }
}

