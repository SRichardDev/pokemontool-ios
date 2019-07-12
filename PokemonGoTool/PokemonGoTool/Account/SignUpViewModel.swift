
import UIKit
import UserNotifications
import FirebaseMessaging
import Firebase

protocol AccountCreationDelegate: class {
    func didCreateAccount(_ status: AuthStatus)
    func failedToCreateAccount(_ status: AuthStatus)
}

protocol AccountSignInDelegate: class {
    func didSignInUser(_ status: AuthStatus)
    func failedToSignIn(_ status: AuthStatus)
}

class SignUpViewModel {
    
    private let firebaseConnector: FirebaseConnector

    weak var accountCreationDelegate: AccountCreationDelegate?
    weak var accountSignInDelegate: AccountSignInDelegate?
    
    var email = ""
    var password = ""
    var trainerName = ""
    var team = Team(rawValue: 0)!
    var level = 40
    
    init(firebaseConnector: FirebaseConnector) {
        self.firebaseConnector = firebaseConnector
    }
    
    func signUpUser() {
        User.signUp(with: email,
                    password: password,
                    trainerName: trainerName,
                    team: team,
                    level: level) { status in
                        
                        switch status {
                        case .signedUp:
                            self.firebaseConnector.loadUser {
                                self.accountCreationDelegate?.didCreateAccount(status)
                                self.registerForPushIfNeeded()
                            }
                        default:
                            self.accountCreationDelegate?.failedToCreateAccount(status)
                        }
        }
    }
    
    func signInUser() {
        User.signIn(with: email, password: password) { status in
            switch status {
            case .signedIn:
                self.firebaseConnector.loadUser {
                    self.accountSignInDelegate?.didSignInUser(status)
                    self.registerForPushIfNeeded()
                }
            default:
                self.accountSignInDelegate?.failedToSignIn(status)
            }
        }
    }
    
    func resetPassword() {
        User.resetPassword(for: email)
    }
    
    private func registerForPushIfNeeded() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions,
                                                                completionHandler: {_, _ in })
        UIApplication.shared.registerForRemoteNotifications()
        
        if let token = Messaging.messaging().fcmToken {
            guard let userID = Auth.auth().currentUser?.uid else {return}
            let database = Database.database().reference(withPath: "users/\(userID)")
            let data = ["notificationToken" : token,
                        "platform" : "iOS"]
            database.updateChildValues(data)
        }
    }
    
    func isValidEmail(_ testString: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testString)
    }
    
    func isValidPassword(_ testString: String) -> Bool {
        let passwordRegex = "^(?=.*[0-9].*[0-9].*[0-9])(?=.*[A-Za-z].*[A-Za-z].*[A-Za-z]).{6,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: testString)
    }
}
