
import UIKit

class AccountEmailViewController: UIViewController, StoryboardInitialViewController {

    weak var coordinator: MainCoordinator?
    var viewModel: AccountViewModel!

    @IBOutlet var subtitleLabel: Label!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var nextButton: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "E-Mail"
        nextButton.isEnabled = false
    }
    
    @IBAction func doneTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
        guard let email = sender.text else { return }
        nextButton.isEnabled = isValidEmail(email)
    }
    
    @IBAction func nextTapped(_ sender: Button) {
        coordinator?.showSignupPassword(viewModel)
    }
    
    @IBAction func viewTapped(_ sender: Any) {
        emailTextField.resignFirstResponder()
        guard let email = emailTextField.text else { return }
        nextButton.isEnabled = isValidEmail(email)
    }
    
    private func isValidEmail(_ testString: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testString)
    }
}
