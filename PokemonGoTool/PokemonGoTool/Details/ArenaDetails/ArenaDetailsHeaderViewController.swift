
import UIKit

class ArenaDetailsHeaderViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: ArenaDetailsViewModel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = ""//viewModel.isRaidExpired ? viewModel.arena.name : viewModel.arena.raid?.raidBoss?.name
        imageView.image = viewModel.isRaidExpired ? viewModel.arenaImage : viewModel.raidBossImage
    }
}
