
import UIKit

protocol AccountCreationDelegate: class {
    func didCreateAccount(_ status: AuthStatus)
}

class SignUpViewModel {
    
    private let firebaseConnector: FirebaseConnector

    weak var accountCreationDelegate: AccountCreationDelegate?

    var email = ""
    var password = ""
    var trainerName = ""
    var team = Team(rawValue: 0)!
    var level = 1
    
    init(firebaseConnector: FirebaseConnector) {
        self.firebaseConnector = firebaseConnector
    }
    
    func signUpUser() {
        User.signUp(with: email,
                    password: password,
                    trainerName: trainerName,
                    team: team,
                    level: level) { status in
                        
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
        let passwordRegex = "^(?=.*[0-9].*[0-9].*[0-9])(?=.*[A-Za-z].*[A-Za-z].*[A-Za-z]).{6,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: testString)
    }
}
