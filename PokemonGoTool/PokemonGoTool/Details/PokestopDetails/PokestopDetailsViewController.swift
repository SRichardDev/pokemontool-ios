
import UIKit
import MapKit
class PokestopDetailsViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: PokestopDetailsViewModel!
    weak var coordinator: MainCoordinator?
    private let stackView = OuterVerticalStackView()
    private let headerViewController = HeaderViewController.fromStoryboard()
    private let questViewController = PokestopQuestViewController.fromStoryboard()
    private let infoViewController = PokestopInfoViewController.fromStoryboard()

    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.addToView(view)
        
        headerViewController.viewModel = viewModel
        questViewController.viewModel = viewModel
        infoViewController.viewModel = viewModel

        let mapViewController = SubmitMapViewController.setup(with: viewModel.coordinate)
        
        stackView.addArrangedViewController(headerViewController, to: self)
        
        if viewModel.hasActiveQuest {
            stackView.addArrangedViewController(questViewController, to: self)
        }
        
        stackView.addArrangedViewController(mapViewController, to: self)
        stackView.addArrangedViewController(infoViewController, to: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle("Pokéstop")
    }
}
