
import UIKit

class AccountPasswordViewController: UIViewController, StoryboardInitialViewController {

    weak var coordinator: MainCoordinator?
    var viewModel: AccountViewModel!

    @IBOutlet var titleLabel: Label!
    @IBOutlet var subtitleLabel: Label!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Passwort"
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        
    }
}
