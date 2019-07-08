
import UIKit

class AccountSignUpViewController: UIViewController, StoryboardInitialViewController, AccountCreationDelegate, FirebaseStatusPresentable {
    
    weak var coordinator: MainCoordinator?
    var viewModel: SignUpViewModel!
    
    @IBOutlet var emailTitleLabel: Label!
    @IBOutlet var emailLabel: Label!
    @IBOutlet var passwordTitleLabel: Label!
    @IBOutlet var passwordLabel: Label!
    @IBOutlet var trainerNameTitleLabel: Label!
    @IBOutlet var trainerNameLabel: Label!
    @IBOutlet var teamLabel: Label!
    @IBOutlet var levelLabel: Label!
    
    @IBOutlet var signUpButton: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Prüfen"
        viewModel.accountCreationDelegate = self
        signUpButton.setTitle("Account erstellen", for: .normal)
        emailLabel.text = viewModel.email
        passwordLabel.text = String(viewModel.password.map { _ in return "•" })
        trainerNameLabel.text = "Trainer Name: \(viewModel.trainerName)"
        teamLabel.text = "Team: \(viewModel.team.description)"
        levelLabel.text = "Level: \(viewModel.level)"
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        viewModel.signUpUser()
        showSpinner()
    }
    
    func didCreateAccount(_ status: AuthStatus) {
        showAlert(for: status)
        removeSpinner()
        
        switch status {
        case .signedUp:
            navigationController?.popToRootViewController(animated: true)
        default:
            break
        }
    }
    
    func failedToCreateAccount(_ status: AuthStatus) {
        showAlert(for: status)
        removeSpinner()
    }
}
