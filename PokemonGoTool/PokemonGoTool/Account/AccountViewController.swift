
import UIKit
import Firebase
import NotificationBannerSwift

class AccountViewController: UIViewController, UITextFieldDelegate, FirebaseUserDelegate, StoryboardInitialViewController {
    
    weak var coordinator: MainCoordinator?
    var viewModel: AccountViewModel!

    private let stackView = StackView()
    private let accountOverviewViewController = AccountOverviewViewController.fromStoryboard()
    private let changeDetailsButton = Button()
    private let createAccountButton = Button()

    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.addToView(view)
        accountOverviewViewController.viewModel = viewModel

        changeDetailsButton.setTitle("Infos bearbeiten", for: .normal)
        changeDetailsButton.addAction { [weak self] in
            guard let self = self else { return }
            self.coordinator?.showTeamAndLevel(self.viewModel)
        }
        
        createAccountButton.setTitle("Account anlegen", for: .normal)
        createAccountButton.addAction(for: .touchUpInside) { [weak self] in
            guard let self = self else { return }
            self.coordinator?.showAccountInput(self.viewModel, type: .email)
        }
        
        stackView.addArrangedViewController(viewController: accountOverviewViewController, to: self)
        stackView.addArrangedSubview(changeDetailsButton)
        stackView.addArrangedSubview(createAccountButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        tabBarController?.tabBar.isHidden = false
        
        createAccountButton.isHidden = viewModel.isLoggedIn
        changeDetailsButton.isVisible = viewModel.isLoggedIn
        accountOverviewViewController.view.isVisible = viewModel.isLoggedIn
        
        if viewModel.isLoggedIn {
            let logoutItem = UIBarButtonItem(title: "Abmelden", style: .plain, target: self, action: #selector(logout))
            navigationController?.topViewController?.navigationItem.rightBarButtonItem = logoutItem
        } else {
            navigationController?.topViewController?.navigationItem.rightBarButtonItem = nil
        }
        
//        updateUI()
//
//        Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: { _, _ in
//            Auth.auth().currentUser?.reload(completion: { error in
//                DispatchQueue.main.async {
//                    if Auth.auth().currentUser?.isEmailVerified ?? false {
//                        self.emailVerifiedLabel.text = "E-Mail ist verifiziert."
//                    } else {
//                        self.emailVerifiedLabel.text = "Bitte verifiziere deine E-Mail Adresse. Bitte sehe in deinem Posteingang nach."
//                    }
//                }
//            })
//        })
    }
    
    @objc
    func logout() {
        do {
            try Auth.auth().signOut()
            print("signed out")
//            showAlert(for: .signedOut)
//            self.updateUI()
        } catch let error {
            print(error)
//            showAlert(for: .unknown(error: error.localizedDescription))
        }
    }
    
    @IBAction func loginTapped(_ sender: Any) {
//        if firebaseConnector.isSignedIn {
//        } else {
//            guard let email = emailTextField.text else {return}
//            guard let password = passwordTextField.text else {return}
//
//            User.signIn(with: email, password: password) { status in
//                self.showAlert(for: status)
//                self.firebaseConnector.loadUser()
//            }
//        }
//        emailTextField.resignFirstResponder()
//        passwordTextField.resignFirstResponder()
    }
    
    @IBAction func signupTapped(_ sender: Any) {
//        guard let email = emailTextField.text else { return }
//        guard let password = passwordTextField.text else { return }
//
//        User.signUp(with: email, password: password) { status in
//            self.showAlert(for: status)
//            self.firebaseConnector.loadUser()
//        }
//        emailTextField.resignFirstResponder()
//        passwordTextField.resignFirstResponder()
    }
    
    func updateUI() {
//        let isSignedIn = firebaseConnector.isSignedIn
//        signUpButton.isHidden = isSignedIn
//        isSignedIn ? loginButton.setTitle("Sign out", for: .normal) : loginButton.setTitle("Sign in", for: .normal)
//        emailTextField.isEnabled = !isSignedIn
//        emailTextField.text = firebaseConnector.user?.email
//        passwordLabel.text = isSignedIn ? "Trainer Name:" : "Password:"
//        passwordTextField.text = isSignedIn ? firebaseConnector.user?.trainerName : ""
//        passwordTextField.isSecureTextEntry = !isSignedIn
    }
    
    @IBAction func viewTapped(_ sender: Any) {
//        emailTextField.resignFirstResponder()
//        passwordTextField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        if firebaseConnector.isSignedIn {
//            guard let trainerName = textField.text else { return }
//            firebaseConnector.user?.updateTrainerName(trainerName)
//        }
    }
    
    func didUpdateUser() {
        updateUI()
    }
}
