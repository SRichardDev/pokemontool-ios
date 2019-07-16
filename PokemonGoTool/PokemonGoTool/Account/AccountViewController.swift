
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

    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.addToView(view)
        
        accountWelcomeViewController.coordinator = coordinator
        accountOverviewViewController.coordinator = coordinator
        accountOverviewViewController.viewModel = viewModel
        accountMedalViewController.viewModel = viewModel.accountMedalViewModel
        pushActiveSwitchViewController.viewModel = viewModel
        
        stackView.addArrangedViewController(accountWelcomeViewController, to: self)
        stackView.addArrangedViewController(accountOverviewViewController, to: self)
        stackView.addArrangedViewController(pushActiveSwitchViewController, to: self)
        stackView.addArrangedViewController(accountMedalViewController, to: self)
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
        pushActiveSwitchViewController.view.isVisible = viewModel.isLoggedIn
        
        let logoutItem = UIBarButtonItem(title: "Abmelden", style: .plain, target: self, action: #selector(logout))
        navigationController?.topViewController?.navigationItem.rightBarButtonItem = viewModel.isLoggedIn ? logoutItem : nil
    }
}
