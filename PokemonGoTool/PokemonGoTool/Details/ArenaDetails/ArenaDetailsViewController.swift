
import UIKit

class ArenaDetailsViewController: UIViewController, StoryboardInitialViewController, ArenaDetailsDelegate {
    
    weak var coordinator: MainCoordinator?
    var viewModel: ArenaDetailsViewModel!
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let headerViewController = ArenaDetailsHeaderViewController.instantiateFromStoryboard()
    private let participantsTableViewController = ArenaDetailsParticipantsTableViewController.instantiateFromStoryboard()
    private let participantsOverviewViewController = ArenaDetailsParticipantsOverviewViewController.instantiateFromStoryboard()
    private let restTimeViewController = ArenaDetailsRestTimeViewController.instantiateFromStoryboard()
    private let infoViewController = ArenaDetailsInfoViewController.instantiateFromStoryboard()
    private let meetupTimeViewController = ArenaDetailsMeetupTimeViewController.instantiateFromStoryboard()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviewAndEdgeConstraints(stackView,
                                          edges: .all,
                                          margins: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
                                          constrainToSafeAreaGuide: false)
        
        imageView.image = viewModel.isRaidExpired ? UIImage(named: "arena") : viewModel.raidBossImage
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        headerViewController.viewModel = viewModel
        restTimeViewController.viewModel = viewModel
        participantsTableViewController.viewModel = viewModel
        participantsOverviewViewController.viewModel = viewModel
        participantsOverviewViewController.coordinator = coordinator
        infoViewController.viewModel = viewModel
        meetupTimeViewController.viewModel = viewModel

        stackView.addArrangedViewController(viewController: headerViewController, to: self)
        stackView.addSepartor()
        
        if !viewModel.isRaidExpired {
            stackView.addArrangedViewController(viewController: restTimeViewController, to: self)
            stackView.addSepartor()
            stackView.addArrangedViewController(viewController: meetupTimeViewController, to: self)
            stackView.addSepartor()
            stackView.addArrangedViewController(viewController: participantsOverviewViewController, to: self)
            stackView.addSepartor()
        }
        stackView.addArrangedViewController(viewController: infoViewController, to: self)
        
        restTimeViewController.view.isHidden = viewModel.isRaidExpired
        participantsOverviewViewController.view.isHidden = viewModel.isRaidExpired
   }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.topViewController?.navigationItem.title = viewModel.title
    }
    
    func updateUI() {
        restTimeViewController.view.isHidden = viewModel.isRaidExpired
    }
    
    var animating = false
    func update(of type: ArenaDetailsUpdateType) {
        updateUI()
        switch type {
        case .meetupChanged:
            participantsOverviewViewController.updateUI()
            meetupTimeViewController.updateUI()
        case .timeLeftChanged(let timeLeft):
            restTimeViewController.updateTime(timeLeft)
        }
    }
}
