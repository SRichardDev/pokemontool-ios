
import UIKit
import Firebase
class AccountViewController: UIViewController, AppModuleAccessible, FirebaseStatusPresentable {    
    
    var firebaseConnector: FirebaseConnector!
    var locationManager: LocationManager!
    
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordLabel: UILabel!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        signUpButton.setTitleColor(.lightGray, for: .disabled)
        updateButtons()
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        if firebaseConnector.isSignedIn {
            do {
                try Auth.auth().signOut()
                showAlert(for: .signedOut)
                self.updateButtons()
            } catch let error {
                showAlert(for: .unknown(error: error.localizedDescription))
            }
        } else {
            guard let email = emailTextField.text else {return}
            guard let password = passwordTextField.text else {return}
            
            firebaseConnector.signInUser(with: email, password: password) { status in
                self.showAlert(for: status)
                self.updateButtons()
            }
        }

        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction func signupTapped(_ sender: Any) {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        firebaseConnector.signUpUser(with: email, password: password) { status in
            self.showAlert(for: status)
            self.updateButtons()
        }
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        updateButtons()
    }
    
    func updateButtons() {
        let isSignedIn = firebaseConnector.isSignedIn
        signUpButton.isEnabled = !isSignedIn
        isSignedIn ? loginButton.setTitle("Sign out", for: .normal) : loginButton.setTitle("Sign in", for: .normal)
        isSignedIn ? (signUpButton.backgroundColor = #colorLiteral(red: 0.94599998, green: 0.4300000072, blue: 0.2220000029, alpha: 1).withAlphaComponent(0.5)) : (signUpButton.backgroundColor = #colorLiteral(red: 0.94599998, green: 0.4300000072, blue: 0.2220000029, alpha: 1))
        emailTextField.isEnabled = !isSignedIn
        passwordLabel.isHidden = isSignedIn
        passwordTextField.isHidden = isSignedIn
        
        
    }
    
    @IBAction func viewTapped(_ sender: Any) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
}
