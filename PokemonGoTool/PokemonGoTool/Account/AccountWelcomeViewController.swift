
import UIKit

class AccountWelcomeViewController: UIViewController, StoryboardInitialViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = UIImage(named: "Account")
    }
}
