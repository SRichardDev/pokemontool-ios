
import UIKit
import Firebase
class AccountViewController: UIViewController, AppModuleAccessible, FirebaseErrorPresentable {    
    
    var firebaseConnector: FirebaseConnector!
    var locationManager: LocationManager!
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loginButton.isEnabled = !firebaseConnector.isSignedIn
        signUpButton.isEnabled = !firebaseConnector.isSignedIn
        signOutButton.isEnabled = firebaseConnector.isSignedIn
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        firebaseConnector.signInUser(with: email, password: password) { error in
            guard let error = error else {
                self.showAlert(with: "Success", message: "Signed in successfully")
                return
            }
            
            switch error {
            case .invalidCredential:
                self.showAlert(with: "Error", message: "Invalid Credential")
            case .invalidEmail:
                self.showAlert(with: "Error", message: "Invalid E-Mail")
            case .networkError:
                self.showAlert(with: "Error", message: "Network error")
            case .missingEmail:
                self.showAlert(with: "Error", message: "Missing E-Mail")
            case .unknown(let error):
                self.showAlert(with: "Error", message: "\(error)")
            default:
                print("Unhandled error")
            }
        }
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction func signupTapped(_ sender: Any) {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        firebaseConnector.signUpUser(with: email, password: password) { error in
            guard let error = error else {
                self.showAlert(with: "Success", message: "Please check your E-Mail inbox and verify your account")
                return
            }
            switch error {
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
            case .unknown(let error):
                self.showAlert(with: "Error", message: "\(error)")
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

