
import UIKit

class SubmitRaidDetailsViewController: UIViewController, StoryboardInitialViewController {

    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Neuer Raid"
    }
}
