
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
    
    func updateArenaImage(isGold: Bool) {
        UIView.transition(with: imageView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            self.imageView.image = self.viewModel.isRaidExpired ? self.viewModel.arenaImage : self.viewModel.raidBossImage
        }) { _ in
            
        }
    }
}
