
import UIKit
import Firebase

class AccountViewController: UIViewController, FirebaseStatusPresentable, UITextFieldDelegate, FirebaseUserDelegate, StoryboardInitialViewController {
    
    weak var coordinator: MainCoordinator?
    var firebaseConnector: FirebaseConnector!

    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordLabel: UILabel!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var emailVerifiedLabel: Label!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseConnector.userDelegate = self
        passwordTextField.delegate = self
        emailVerifiedLabel.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        
        Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: { _, _ in
            Auth.auth().currentUser?.reload(completion: { error in
                DispatchQueue.main.async {
                    if Auth.auth().currentUser?.isEmailVerified ?? false {
                        self.emailVerifiedLabel.text = "E-Mail ist verifiziert."
                    } else {
                        self.emailVerifiedLabel.text = "Bitte verifiziere deine E-Mail Adresse. Bitte sehe in deinem Posteingang nach."
                    }
                }
            })
        })
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
        emailTextField.text = firebaseConnector.user?.email
        passwordLabel.text = isSignedIn ? "Trainer Name:" : "Password:"
        passwordTextField.text = isSignedIn ? firebaseConnector.user?.trainerName : ""
        passwordTextField.isSecureTextEntry = !isSignedIn
    }
    
    @IBAction func viewTapped(_ sender: Any) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if firebaseConnector.isSignedIn {
            guard let trainerName = textField.text else { return }
            firebaseConnector.user?.updateTrainerName(trainerName)
        }
    }
    
    func didUpdateUser() {
        updateUI()
    }
}

