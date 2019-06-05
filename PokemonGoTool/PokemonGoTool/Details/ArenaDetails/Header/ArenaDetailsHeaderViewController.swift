
import UIKit

class ArenaDetailsHeaderViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: ArenaDetailsViewModel!
    weak var coordinator: MainCoordinator?
    
    @IBOutlet var titleLabel: Label!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var selectRaidbossButton: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = viewModel.title
        imageView.image = viewModel.isRaidExpired ? viewModel.arenaImage : viewModel.raidBossImage
        selectRaidbossButton.isHidden = viewModel.isRaidExpired
        selectRaidbossButton.setTitle("Raidboss auswählen", for: .normal)
    }
    
    func updateArenaImage(isGold: Bool) {
        UIView.transition(with: imageView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            self.imageView.image = self.viewModel.isRaidExpired ? self.viewModel.arenaImage : self.viewModel.raidBossImage
        })
    }
    
    @IBAction func didTapSelectRaidboss(_ sender: Any) {
        coordinator?.showPokemonSelection(viewModel: viewModel)
    }
}
