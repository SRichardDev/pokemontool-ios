
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
        
        let questViewController = PokestopQuestViewController.fromStoryboard()
        questViewController.viewModel = viewModel
        
        let mapViewController = SubmitMapViewController()
        mapViewController.locationOnMap = viewModel.coordinate
        mapViewController.mapView.mapType = .satelliteFlyover
        mapViewController.isFlyover = true
        
        let infoViewController = PokestopInfoViewController.fromStoryboard()
        infoViewController.viewModel = viewModel
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedViewController(viewController: mapViewController, to: self)
        stackView.addSepartor()
        
        if viewModel.hasActiveQuest {
            stackView.addArrangedViewController(viewController: questViewController, to: self)
            stackView.addSepartor()
        }
        
        stackView.addArrangedViewController(viewController: infoViewController, to: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle("Pokéstop")
    }
}
