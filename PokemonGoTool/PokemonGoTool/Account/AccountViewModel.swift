
import UIKit

protocol AccountCreationDelegate: class {
    func didCreateAccount(_ status: AuthStatus)
}

class AccountViewModel {
    
    private let firebaseConnector: FirebaseConnector
    
    weak var accountCreationDelegate: AccountCreationDelegate?
    
    var email = ""
    var password = ""

    var trainerName: String {
        get {
            return firebaseConnector.user?.trainerName ?? "Kein Trainer Name gesetzt"
        }
    }
    
    var currentTeam: Int {
        get {
            return firebaseConnector.user?.team?.rawValue ?? 0
        }
    }
    
    var teamColor: UIColor? {
        get {
            return firebaseConnector.user?.teamColor
        }
    }
    
    var currentLevel: Int {
        get {
            return 40 - (firebaseConnector.user?.level ?? 0)
        }
    }
    
    var isLoggedIn: Bool {
        get {
            return firebaseConnector.isSignedIn
        }
    }
    
    init(firebaseConnector: FirebaseConnector) {
        self.firebaseConnector = firebaseConnector
    }
    
    func updateTeam(_ team: Team) -> UIColor? {
        firebaseConnector.user?.updateTeam(team)
        return firebaseConnector.user?.teamColor
    }
    
    func updateLevel(_ level: Int) {
        firebaseConnector.user?.updateTrainerLevel(level)
    }
    
    func signUpUser() {
        User.signUp(with: email, password: password) { status in
            self.accountCreationDelegate?.didCreateAccount(status)
            
            switch status {
            case .signedUp:
                self.firebaseConnector.loadUser()
            default:
                break
            }
        }
    }
    
    func isValidEmail(_ testString: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testString)
    }
    
    func isValidPassword(_ testString: String) -> Bool {
        let passwordRegex = "^(?=.*[0-9].*[0-9].*[0-9])(?=.*[a-z].*[a-z].*[a-z]).{6,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: testString)
    }
}
