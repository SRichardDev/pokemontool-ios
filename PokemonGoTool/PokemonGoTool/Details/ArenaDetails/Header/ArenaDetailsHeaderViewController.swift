
import UIKit

class ArenaDetailsHeaderViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: ArenaDetailsViewModel!
    weak var coordinator: MainCoordinator?
    
    @IBOutlet var titleLabel: Label!
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = viewModel.arena.name
        imageView.image = viewModel.headerImage
    }
    
    func updateUI() {
        UIView.transition(with: imageView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            self.imageView.image = self.viewModel.headerImage
        })
    }
    
    @IBAction func didTapSelectRaidboss(_ sender: Any) {
        coordinator?.showPokemonSelection(viewModel: viewModel)
    }
}
