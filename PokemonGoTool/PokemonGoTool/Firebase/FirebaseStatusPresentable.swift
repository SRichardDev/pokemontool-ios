
import UIKit

extension FirebaseStatusPresentable where Self: UIViewController & AppModuleAccessible {
    
    func showAlert(for status: AuthStatus) {
        
        var title = "Error"
        var message = ""
        
        switch status {
        case .weakPassword:
            message = "Weak password"
        case .invalidCredential:
            message = "Invalid Credential"
        case .emailAlreadyInUse:
            message = "Email already in use"
        case .invalidEmail:
            message = "Invalid E-Mail"
        case .networkError:
            message = "Network error"
        case .missingEmail:
            message = "Missing E-Mail"
        case .unknown(let error):
            message = error
        case .signedUp:
            title = "Success"
            message = "Please check your E-Mail inbox and verify your account"
        case .signedIn:
            title = "Success"
            message = "Welcome back"
        case .signedOut:
            title = "Success"
            message = "Signed out"
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
