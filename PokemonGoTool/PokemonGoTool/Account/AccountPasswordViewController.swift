
import UIKit

class AccountPasswordViewController: UIViewController, StoryboardInitialViewController {

    weak var coordinator: MainCoordinator?
    var viewModel: AccountViewModel!

    @IBOutlet var subtitleLabel: Label!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var nextButton: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Passwort"
        nextButton.isEnabled = false
    }
    
    @IBAction func doneTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
        guard let password = sender.text else { return }
        nextButton.isEnabled = isValidPassword(password)
    }
    
    @IBAction func viewTapped(_ sender: Any) {
        passwordTextField.resignFirstResponder()
        guard let password = passwordTextField.text else { return }
        nextButton.isEnabled = isValidPassword(password)
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        
    }
    
    private func isValidPassword(_ testString: String) -> Bool {
        let passwordRegex = "^(?=.*[0-9].*[0-9].*[0-9])(?=.*[a-z].*[a-z].*[a-z]).{6,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: testString)
    }
}
