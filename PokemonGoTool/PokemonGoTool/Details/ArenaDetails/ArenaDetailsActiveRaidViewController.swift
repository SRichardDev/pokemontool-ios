
import UIKit

class ArenaDetailsActiveRaidViewController: UIViewController, StoryboardInitialViewController, RaidTimeLeftDelegate {
    var viewModel: ArenaDetailsViewModel!

    @IBOutlet var bossEggImageView: UIImageView!
    @IBOutlet var bossEggNameLabel: Label!
    @IBOutlet var restTimeLabel: Label!
    @IBOutlet var participantsTitleLabel: Label!
    @IBOutlet var participantsLabel: Label!
    @IBOutlet var participateButton: Button!
    @IBOutlet var chatTitleLabel: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restTimeLabel.text = "-- : -- : --"
        viewModel.delegate = self
        bossEggImageView.image = viewModel.image
        bossEggNameLabel.text = viewModel.arena.raid?.raidBoss?.name
    }
    
    func didUpdateTimeLeft(_ string: String) {
        restTimeLabel.text = string
    }
    
    @IBAction func participateTapped(_ sender: Any) {
        
    }
}
