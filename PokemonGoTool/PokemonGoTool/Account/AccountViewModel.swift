
import UIKit

protocol AccountCreationDelegate: class {
    func didCreateAccount(success: Bool)
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
//            self.showAlert(for: status)
            self.firebaseConnector.loadUser()
            self.accountCreationDelegate?.didCreateAccount(success: true)
        }
    }
}
