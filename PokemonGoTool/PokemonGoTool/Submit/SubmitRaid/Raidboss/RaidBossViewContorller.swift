
import UIKit
import NSTAppKit

class RaidBossViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: RaidbossSelectable!
    @IBOutlet var selectedPokemonImageView: UIImageView!
    @IBOutlet var nameLabel: Label!
    @IBOutlet var selectRaidbossButton: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
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
        selectRaidbossButton.setTitle("Raidboss auswählen", for: .normal)
        selectedPokemonImageView.image = ImageManager.image(named: "\(viewModel.selectedRaidBoss ?? 0)")
        selectedPokemonImageView.isHidden = selectedPokemonImageView.image == nil
        nameLabel.text = RaidbossManager.shared.pokemonNameFor(dexNumber: viewModel.selectedRaidBoss)
        nameLabel.isHidden = selectedPokemonImageView.image == nil
    }
}
