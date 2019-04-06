
import UIKit

class AccountOverviewViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: AccountViewModel!

    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var levelLabel: Label!
    @IBOutlet var trainerNameLabel: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        levelLabel.text = "\(viewModel.currentLevel)"
        trainerNameLabel.text = viewModel.trainerName
    }
}
