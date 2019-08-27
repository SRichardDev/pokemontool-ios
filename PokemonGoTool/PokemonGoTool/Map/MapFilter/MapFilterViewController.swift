
import UIKit

class MapFilterViewController: UIViewController, StoryboardInitialViewController {

    private let stackView = OuterVerticalStackView()
    private let arenaFilterViewController = ArenaFilterViewController.fromStoryboard()
    private let pokestopFilterViewController = PokestopFilterViewController.fromStoryboard()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView.addToView(view)
        stackView.addArrangedViewController(arenaFilterViewController, to: self)
        stackView.addArrangedViewController(pokestopFilterViewController, to: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle("Filter")
        AppSettings.filterSettingsChanged = true
    }
}

