
import UIKit

class PokestopQuestViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: PokestopDetailsViewModel!
    
    @IBOutlet var activeQuestTitleLabel: Label!
    @IBOutlet var activeQuestLabel: Label!
    @IBOutlet var rewardTitleLabel: Label!
    @IBOutlet var rewardLabel: Label!
    @IBOutlet var rewardImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activeQuestLabel.text = viewModel.pokestop.quest?.name
        rewardLabel.text = viewModel.pokestop.quest?.reward
        rewardImageView.image = ImageManager.image(named: viewModel.rewardImageName)
    }
}
