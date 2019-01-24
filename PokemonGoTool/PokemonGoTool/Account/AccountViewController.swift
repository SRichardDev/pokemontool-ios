
import UIKit
import Firebase

class AccountViewController: UIViewController, AppModuleAccessible, FirebaseStatusPresentable, UITextFieldDelegate {
    
    var firebaseConnector: FirebaseConnector!
    var locationManager: LocationManager!
    private var user: User? {
        didSet {
            updateUI()
        }
    }
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordLabel: UILabel!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
    
    override func viewDidLoad() {
        passwordTextField.delegate = self
        User.loadUser { user in
            self.user = user
        }
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        if firebaseConnector.isSignedIn {
            do {
                try Auth.auth().signOut()
                showAlert(for: .signedOut)
                self.updateUI()
            } catch let error {
                showAlert(for: .unknown(error: error.localizedDescription))
            }
        } else {
            guard let email = emailTextField.text else {return}
            guard let password = passwordTextField.text else {return}
            
            User.signIn(with: email, password: password) { status in
                self.showAlert(for: status)
                self.updateUI()
            }
        }

        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction func signupTapped(_ sender: Any) {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        User.signUp(with: email, password: password) { status in
            self.showAlert(for: status)
            self.updateUI()
        }
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        updateUI()
    }
    
    func updateUI() {
        let isSignedIn = firebaseConnector.isSignedIn
        signUpButton.isHidden = isSignedIn
        isSignedIn ? loginButton.setTitle("Sign out", for: .normal) : loginButton.setTitle("Sign in", for: .normal)
        emailTextField.isEnabled = !isSignedIn
        emailTextField.text = user?.email
        passwordLabel.text = isSignedIn ? "Trainer Name:" : "Password:"
        passwordTextField.text = isSignedIn ? user?.trainerName : ""
        passwordTextField.isSecureTextEntry = !isSignedIn
    }
    
    @IBAction func viewTapped(_ sender: Any) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if firebaseConnector.isSignedIn {
            guard let trainerName = textField.text else { return }
            user?.updateTrainerName(trainerName)
        }
    }
}

