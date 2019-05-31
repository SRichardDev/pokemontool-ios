
import UIKit

class PokestopQuestViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: PokestopDetailsViewModel!
    
    @IBOutlet var activeQuestTitleLabel: Label!
    @IBOutlet var activeQuestLabel: Label!
    @IBOutlet var rewardTitleLabel: Label!
    @IBOutlet var rewardLabel: Label!
    @IBOutlet var rewardImageView: UIImageView!
    @IBOutlet var submitterTitleLabel: Label!
    @IBOutlet var submitterLabel: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activeQuestLabel.text = "Aktive Quest:"
        rewardTitleLabel.text = "Belohnung:"
        submitterTitleLabel.text = "Eingereicht von:"
        
        activeQuestLabel.text = viewModel.questDefinition?.quest
        rewardLabel.text = viewModel.questDefinition?.reward
        rewardImageView.image = viewModel.questDefinition?.image
        viewModel.questSubmitterName(completion: { self.submitterLabel.text = $0 })
    }
}
