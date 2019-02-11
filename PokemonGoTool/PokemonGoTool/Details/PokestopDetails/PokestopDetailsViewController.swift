
import UIKit
import MapKit
class PokestopDetailsViewController: UIViewController, StoryboardInitialViewController, MapEmbeddable {
    
    var viewModel: PokestopDetailsViewModel!
    weak var coordinator: MainCoordinator?
    @IBOutlet var titleLabel: Label!
    @IBOutlet var containerView: UIView!
    private var mapViewController: SubmitMapViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapViewController = embedMap(coordinate: viewModel.coordinate)
        titleLabel.text = viewModel.pokestop.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle("Pokéstop")
    }
}
