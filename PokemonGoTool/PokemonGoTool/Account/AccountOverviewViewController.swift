
import UIKit

class AccountOverviewViewController: UIViewController, StoryboardInitialViewController {

    weak var coordinator: MainCoordinator?
    var viewModel: AccountViewModel!

    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var levelLabel: Label!
    @IBOutlet var trainerNameLabel: Label!
    @IBOutlet var changeDetailsButton: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeDetailsButton.setTitle("Infos bearbeiten", for: .normal)
        changeDetailsButton.addAction(for: .touchUpInside) { [unowned self] in
            self.coordinator?.showTeamAndLevel(accountViewModel: self.viewModel)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        headerImageView.image = viewModel.currentTeam?.image
        levelLabel.text = "\(viewModel.currentLevel)"
        trainerNameLabel.text = viewModel.trainerName
    }
}
