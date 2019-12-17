
import UIKit
import NSTAppKit

class RaidBossViewController: UIViewController, StoryboardInitialViewController {
    @IBOutlet var selectedPokemonImageView: UIImageView!
    @IBOutlet var selectRaidbossButton: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectRaidbossButton.setTitle("Raidboss auswählen", for: .normal)
    }
    
    @IBAction func showPokemonSelectionTapped(_ sender: Any) {
        let pokemonViewController = PokemonTableViewController.fromStoryboard()
        let navigationController = NavigationController()
        navigationController.viewControllers = [pokemonViewController]
        present(navigationController, animated: true)
    }
}
