
import UIKit
import NSTAppKit

class RaidBossViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: SubmitRaidViewModel!
    @IBOutlet var selectedPokemonImageView: UIImageView!
    @IBOutlet var selectRaidbossButton: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectRaidbossButton.setTitle("Raidboss auswählen", for: .normal)
    }
    
    @IBAction func showPokemonSelectionTapped(_ sender: Any) {
        let pokemonViewController = PokemonTableViewController.fromStoryboard()
        pokemonViewController.selectedRaidbossCallback = { [weak self] dexNumber in
            self?.viewModel.updateRaidboss(dexNumber: dexNumber)
        }
        
        let navigationController = NavigationController()
        navigationController.viewControllers = [pokemonViewController]
        present(navigationController, animated: true)
    }
    
    func updateUI() {
        selectedPokemonImageView.image = ImageManager.image(named: "\(viewModel.selectedRaidBoss ?? 0)")
    }
}
