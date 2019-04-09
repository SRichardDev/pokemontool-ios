
import UIKit

class AccountOverviewViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: AccountViewModel!

    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var levelLabel: Label!
    @IBOutlet var trainerNameLabel: Label!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        headerImageView.image = viewModel.currentTeam?.image
        levelLabel.text = "\(viewModel.currentLevel)"
        trainerNameLabel.text = viewModel.trainerName
    }
}
