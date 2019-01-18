
import UIKit
import Firebase
class AccountViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                if let errorCode = AuthErrorCode(rawValue: error._code) {
                    switch errorCode {
                    case .invalidCredential:
                        self.showAlert(with: "Error", message: "Invalid Credential")
                    case .invalidEmail:
                        self.showAlert(with: "Error", message: "Invalid E-Mail")
                    case .networkError:
                        self.showAlert(with: "Error", message: "Network error")
                    case .missingEmail:
                        self.showAlert(with: "Error", message: "Missing E-Mail")
                    default:
                        self.showAlert(with: "Error", message: "\(error.localizedDescription)")
                    }
                }
            } else {
                self.showAlert(with: "Success", message: "Signed in successfully")
            }
        }
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction func signupTapped(_ sender: Any) {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                if let errorCode = AuthErrorCode(rawValue: error._code) {
                    switch errorCode {
                    case .weakPassword:
                        self.showAlert(with: "Error", message: "Weak password")
                    case .invalidCredential:
                        self.showAlert(with: "Error", message: "Invalid Credential")
                    case .emailAlreadyInUse:
                        self.showAlert(with: "Error", message: "Email already in use")
                    case .invalidEmail:
                        self.showAlert(with: "Error", message: "Invalid E-Mail")
                    case .networkError:
                        self.showAlert(with: "Error", message: "Network error")
                    case .missingEmail:
                        self.showAlert(with: "Error", message: "Missing E-Mail")
                    default:
                        self.showAlert(with: "Error", message: "\(error.localizedDescription)")
                    }
                }
                print(error.localizedDescription)
            }
            
            if result != nil {
                result?.user.sendEmailVerification() { error in
                    self.showAlert(with: "Success", message: "Please check your E-Mail inbox and verify your account")
                }
            }
        }
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction func signOut() {
        do {
            try Auth.auth().signOut()
            showAlert(with: "Success", message: "Signed out")
        } catch let error {
            showAlert(with: "Error", message: error.localizedDescription)
        }
    }
}

extension UIViewController {
    func showAlert(with title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
