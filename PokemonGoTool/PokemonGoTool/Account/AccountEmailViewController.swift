
import UIKit

class AccountEmailViewController: UIViewController, StoryboardInitialViewController {

    weak var coordinator: MainCoordinator?
    var viewModel: AccountViewModel!

    @IBOutlet var titleLabel: Label!
    @IBOutlet var subtitleLabel: Label!
    @IBOutlet var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "E-Mail"
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        
    }
}
