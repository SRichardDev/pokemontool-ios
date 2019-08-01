
import UIKit
import MapKit
class PokestopDetailsViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: PokestopDetailsViewModel!
    weak var coordinator: MainCoordinator?
    private let stackView = OuterVerticalStackView()
    private let headerViewController = HeaderViewController.fromStoryboard()
    private let questViewController = PokestopQuestViewController.fromStoryboard()
    private let infoViewController = PokestopInfoViewController.fromStoryboard()
    private let incidentViewController = PokestopIncidentViewController.fromStoryboard()

    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.addToView(view)
        
        headerViewController.viewModel = viewModel
        questViewController.viewModel = viewModel
        infoViewController.viewModel = viewModel
        incidentViewController.viewModel = viewModel

        let mapViewController = SubmitMapViewController.setup(with: viewModel.coordinate)
        
        stackView.addArrangedViewController(headerViewController, to: self)
        stackView.addArrangedViewController(incidentViewController, to: self)
        stackView.addArrangedViewController(questViewController, to: self)
        stackView.addArrangedViewController(mapViewController, to: self)
        stackView.addArrangedViewController(infoViewController, to: self)
        
        incidentViewController.view.isVisible = viewModel.hasActiveIncident
        questViewController.view.isVisible = viewModel.hasActiveQuest
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle("Pokéstop")
    }
}
