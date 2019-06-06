
import UIKit
import Firebase

class AccountViewController: UIViewController, StoryboardInitialViewController, FirebaseStatusPresentable {
    
    weak var coordinator: MainCoordinator?
    var viewModel: AccountViewModel!

    private let stackView = OuterVerticalStackView()
    private let accountWelcomeViewController = AccountWelcomeViewController.fromStoryboard()
    private let accountOverviewViewController = AccountOverviewViewController.fromStoryboard()
    private let accountMedalViewController = AccountMedalViewController.fromStoryboard()
    private let pushActiveSwitchViewController = AccountPushActiveSwitchViewController.fromStoryboard()
    private let changeDetailsButton = Button()
    private let createAccountButton = Button()
    private let signInButton = Button()

    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.addToView(view)
        
        accountOverviewViewController.viewModel = viewModel
        accountMedalViewController.viewModel = viewModel.accountMedalViewModel
        pushActiveSwitchViewController.viewModel = viewModel
        
        changeDetailsButton.setTitle("Infos bearbeiten", for: .normal)
        changeDetailsButton.addAction(for: .touchUpInside) { [unowned self] in
            self.coordinator?.showTeamAndLevel(accountViewModel: self.viewModel)
        }
        
        createAccountButton.setTitle("Account anlegen", for: .normal)
        createAccountButton.addAction(for: .touchUpInside) { [unowned self] in
            self.coordinator?.showAccountInput(type: .email)
        }
        
        signInButton.setTitle("Anmelden", for: .normal)
        signInButton.addAction(for: .touchUpInside) { [unowned self] in
            self.coordinator?.showAccountInput(type: .emailSignIn)
        }
        
        stackView.addArrangedViewController(viewController: accountWelcomeViewController, to: self)
        stackView.addArrangedViewController(viewController: accountOverviewViewController, to: self)
        stackView.addArrangedSubview(changeDetailsButton)
        stackView.addSepartor()
        stackView.addArrangedViewController(viewController: pushActiveSwitchViewController, to: self)
        stackView.addSepartor()
        stackView.addArrangedViewController(viewController: accountMedalViewController, to: self)
        stackView.addArrangedSubview(signInButton)
        stackView.addArrangedSubview(createAccountButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()

        #warning("FIX ME")
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
            showAlert(for: .signedOut)
            updateUI()
        } catch let error {
            print(error)
            showAlert(for: .unknown(error: error.localizedDescription))
        }
    }
    
    func updateUI() {
        tabBarController?.tabBar.isHidden = false
        accountWelcomeViewController.view.isHidden = viewModel.isLoggedIn
        accountOverviewViewController.view.isVisible = viewModel.isLoggedIn
        accountMedalViewController.view.isVisible = viewModel.isLoggedIn
        createAccountButton.isHidden = viewModel.isLoggedIn
        signInButton.isHidden = viewModel.isLoggedIn
        changeDetailsButton.isVisible = viewModel.isLoggedIn
        pushActiveSwitchViewController.view.isVisible = viewModel.isLoggedIn
        
        let logoutItem = UIBarButtonItem(title: "Abmelden", style: .plain, target: self, action: #selector(logout))
        navigationController?.topViewController?.navigationItem.rightBarButtonItem = viewModel.isLoggedIn ? logoutItem : nil
    }
}
