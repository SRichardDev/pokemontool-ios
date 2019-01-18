
import UIKit
import Firebase
class AccountViewController: UIViewController, AppModuleAccessible, FirebaseStatusPresentable {    
    
    var firebaseConnector: FirebaseConnector!
    var locationManager: LocationManager!
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateButtons()
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        firebaseConnector.signInUser(with: email, password: password) { status in
            self.showAlert(for: status)
            self.updateButtons()
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
    
    @IBAction func signOut() {
        do {
            try Auth.auth().signOut()
            showAlert(for: .signedOut)
        } catch let error {
            showAlert(for: .unknown(error: error.localizedDescription))
        }
        updateButtons()
    }
    
    func updateButtons() {
        loginButton.isEnabled = !firebaseConnector.isSignedIn
        signUpButton.isEnabled = !firebaseConnector.isSignedIn
        signOutButton.isEnabled = firebaseConnector.isSignedIn
    }
}

