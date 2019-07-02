
import UIKit
import MapKit
class PokestopDetailsViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: PokestopDetailsViewModel!
    weak var coordinator: MainCoordinator?
    private let stackView = OuterVerticalStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.addToView(view)
        
        let titleLabel = Label()
        titleLabel.style = 2
        titleLabel.numberOfLines = 0
        titleLabel.text = viewModel.pokestop.name
        titleLabel.textAlignment = .center
        
        let questViewController = PokestopQuestViewController.fromStoryboard()
        questViewController.viewModel = viewModel
        
        let mapViewController = SubmitMapViewController()
        mapViewController.locationOnMap = viewModel.coordinate
        mapViewController.mapView.mapType = .satelliteFlyover
        mapViewController.isFlyover = true
        mapViewController.view.isUserInteractionEnabled = false
        
        let infoViewController = PokestopInfoViewController.fromStoryboard()
        infoViewController.viewModel = viewModel
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedViewController(viewController: mapViewController, to: self)
        
        if viewModel.hasActiveQuest {
            stackView.addArrangedViewController(viewController: questViewController, to: self)
        }
        
        stackView.addArrangedViewController(viewController: infoViewController, to: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle("Pokéstop")
    }
}
