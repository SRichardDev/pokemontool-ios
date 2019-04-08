
import UIKit

class AccountSignUpViewController: UIViewController, StoryboardInitialViewController, AccountCreationDelegate, FirebaseStatusPresentable {
    
    weak var coordinator: MainCoordinator?
    var viewModel: AccountViewModel!
    
    @IBOutlet var emailTitleLabel: Label!
    @IBOutlet var emailLabel: Label!
    @IBOutlet var passwordTitleLabel: Label!
    @IBOutlet var passwordLabel: Label!
    @IBOutlet var trainerNameTitleLabel: Label!
    @IBOutlet var trainerNameLabel: Label!
    @IBOutlet var teamTitleLabel: Label!
    @IBOutlet var teamLabel: Label!
    @IBOutlet var levelTitleLabel: Label!
    @IBOutlet var levelLabel: Label!
    @IBOutlet var signUpButton: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Prüfen"
        viewModel.accountCreationDelegate = self
        signUpButton.setTitle("Account erstellen", for: .normal)
        emailLabel.text = viewModel.email
        passwordLabel.text = viewModel.password
        trainerNameLabel.text = viewModel.trainerName
        teamLabel.text = "\(viewModel.currentTeam)"
        levelLabel.text = "\(viewModel.currentLevel)"
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        viewModel.signUpUser()
    }
    
    func didCreateAccount(_ status: AuthStatus) {
        showAlert(for: status)
        
        switch status {
        case .signedUp:
            navigationController?.popToRootViewController(animated: true)
        default:
            break
        }
    }
}
