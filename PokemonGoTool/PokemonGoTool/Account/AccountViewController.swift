
import UIKit
import Firebase
import NotificationBannerSwift

class AccountViewController: UIViewController, StoryboardInitialViewController, FirebaseStatusPresentable {
    
    weak var coordinator: MainCoordinator?
    var viewModel: AccountViewModel!

    private let stackView = StackView()
    private let accountOverviewViewController = AccountOverviewViewController.fromStoryboard()
    private let changeDetailsButton = Button()
    private let createAccountButton = Button()
    private let signInButton = Button()

    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.addToView(view)
        accountOverviewViewController.viewModel = viewModel

        changeDetailsButton.setTitle("Infos bearbeiten", for: .normal)
        changeDetailsButton.addAction(for: .touchUpInside) { [weak self] in
            guard let self = self else { return }
            self.coordinator?.showTeamAndLevel(accountViewModel: self.viewModel)
        }
        
        createAccountButton.setTitle("Account anlegen", for: .normal)
        createAccountButton.addAction(for: .touchUpInside) { [weak self] in
            guard let self = self else { return }
            self.coordinator?.showAccountInput(type: .email)
        }
        
        signInButton.setTitle("Anmelden", for: .normal)
        signInButton.addAction(for: .touchUpInside) { [weak self] in
            guard let self = self else { return }
            self.coordinator?.showAccountInput(type: .emailSignIn)
        }
        
        stackView.addArrangedViewController(viewController: accountOverviewViewController, to: self)
        stackView.addArrangedSubview(changeDetailsButton)
        stackView.addArrangedSubview(signInButton)
        stackView.addArrangedSubview(createAccountButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()

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
        createAccountButton.isHidden = viewModel.isLoggedIn
        signInButton.isHidden = viewModel.isLoggedIn
        changeDetailsButton.isVisible = viewModel.isLoggedIn
        accountOverviewViewController.view.isVisible = viewModel.isLoggedIn
        
        let logoutItem = UIBarButtonItem(title: "Abmelden", style: .plain, target: self, action: #selector(logout))
        navigationController?.topViewController?.navigationItem.rightBarButtonItem = viewModel.isLoggedIn ? logoutItem : nil
    }
}
