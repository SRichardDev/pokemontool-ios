
import UIKit
import Firebase
import NotificationBannerSwift

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
    @IBOutlet var teamSelectionSegmentedControl: UISegmentedControl!
    @IBOutlet var levelPickerView: UIPickerView!
    
    var teamPickerViewRows: [String] {
        get {
            var array = [String]()
            array.reserveCapacity(40)
            for index in 1...40 {
                array.append("\(index)")
            }
            return array.reversed()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseConnector.userDelegate = self
        passwordTextField.delegate = self
        emailVerifiedLabel.text = ""
        levelPickerView.delegate = self
        levelPickerView.dataSource = self
        setTitle("Account")
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
                self.firebaseConnector.loadUser()
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
            self.firebaseConnector.loadUser()
        }
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
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
        
        guard let level = firebaseConnector.user?.level else { return }
        levelPickerView.selectRow(40 - level, inComponent: 0, animated: false)

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
    
    @IBAction func didSelectTeam(_ sender: UISegmentedControl) {
        let team = sender.selectedSegmentIndex
        
        if team == 0 {
            sender.tintColor = .blue
            sender.backgroundColor = .white
        } else if team == 1 {
            sender.tintColor = .red
            sender.backgroundColor = .white
        } else if team == 2 {
            sender.tintColor = .yellow
            sender.backgroundColor = .black
        }
        
        firebaseConnector.user?.updateTeam(team)
    }
}

extension AccountViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return teamPickerViewRows[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        firebaseConnector.user?.updateTrainerLevel(Int(teamPickerViewRows[row]) ?? 0)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return teamPickerViewRows.count
    }
}
