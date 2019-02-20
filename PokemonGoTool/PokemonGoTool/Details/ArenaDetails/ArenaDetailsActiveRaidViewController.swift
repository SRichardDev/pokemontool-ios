
import UIKit

class ArenaDetailsActiveRaidViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: ArenaDetailsViewModel!

    @IBOutlet var bossEggImageView: UIImageView!
    @IBOutlet var bossEggNameLabel: UILabel!
    @IBOutlet var restTimeLabel: UILabel!
    @IBOutlet var participantsTitleLabel: UILabel!
    @IBOutlet var participantsLabel: UILabel!
    @IBOutlet var participateButton: Button!
    @IBOutlet var chatTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    
    @IBAction func participateTapped(_ sender: Any) {
        
    }
}
