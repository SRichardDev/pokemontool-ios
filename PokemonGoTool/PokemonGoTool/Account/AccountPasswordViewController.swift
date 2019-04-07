
import UIKit

class AccountPasswordViewController: UIViewController, StoryboardInitialViewController {

    weak var coordinator: MainCoordinator?
    var viewModel: AccountViewModel!

    @IBOutlet var subtitleLabel: Label!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Passwort"
    }
    
    @IBAction func doneTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func viewTapped(_ sender: Any) {
        passwordTextField.resignFirstResponder()
    }
}
