
import UIKit
import MapKit
class PokestopDetailsViewController: UIViewController, StoryboardInitialViewController, MapEmbeddable {
    
    var viewModel: PokestopDetailsViewModel!
    weak var coordinator: MainCoordinator?
    @IBOutlet var titleLabel: Label!
    @IBOutlet var containerView: UIView!
    @IBOutlet var activeQuestTitleLabel: Label!
    @IBOutlet var activeQuestLabel: Label!
    @IBOutlet var rewardTitleLabel: Label!
    @IBOutlet var rewardLabel: Label!
    @IBOutlet var rewardImageView: UIImageView!
    @IBOutlet var coordinateTitleLabel: Label!
    @IBOutlet var coordianteLabel: Label!
    @IBOutlet var submitterTitleLabel: Label!
    @IBOutlet var submitterLabel: Label!
    @IBOutlet var timeStampTitleLabel: Label!
    @IBOutlet var timeStampLabel: Label!
    
    private var mapViewController: SubmitMapViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapViewController = embedMap(coordinate: viewModel.coordinate)
        titleLabel.text = viewModel.pokestop.name
        activeQuestLabel.text = viewModel.pokestop.quest?.name
        rewardLabel.text = viewModel.pokestop.quest?.reward
        rewardImageView.image = ImageManager.image(named: viewModel.rewardImageName)
        coordianteLabel.text = "\(viewModel.coordinate.latitude), \(viewModel.coordinate.longitude)"
        submitterLabel.text = viewModel.pokestop.submitter
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle("Pokéstop")
    }
}
