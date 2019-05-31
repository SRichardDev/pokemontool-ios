
import UIKit

class ArenaDetailsHeaderViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: ArenaDetailsViewModel!
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = viewModel.isRaidExpired ? viewModel.arenaImage : viewModel.raidBossImage
    }
    
    func updateArenaImage(isGold: Bool) {
        UIView.transition(with: imageView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            self.imageView.image = self.viewModel.isRaidExpired ? self.viewModel.arenaImage : self.viewModel.raidBossImage
        }) { _ in
            
        }
    }
}
