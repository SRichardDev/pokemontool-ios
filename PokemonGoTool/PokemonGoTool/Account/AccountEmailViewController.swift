
import UIKit

class AccountEmailViewController: UIViewController, StoryboardInitialViewController {

    weak var coordinator: MainCoordinator?
    var viewModel: AccountViewModel!

    @IBOutlet var titleLabel: Label!
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
    }
    
    private func isValidEmail(_ testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}
