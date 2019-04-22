
import UIKit

class ArenaDetailsViewController: UIViewController, StoryboardInitialViewController, ArenaDetailsDelegate {
    
    weak var coordinator: MainCoordinator?
    var viewModel: ArenaDetailsViewModel!
    private let stackView = OuterVerticalStackView()
    private let imageView = UIImageView()
    private let headerViewController = ArenaDetailsHeaderViewController.fromStoryboard()
    private let participantsTableViewController = ArenaDetailsParticipantsTableViewController.fromStoryboard()
    private let participantsOverviewViewController = ArenaDetailsParticipantsOverviewViewController.fromStoryboard()
    private let restTimeViewController = ArenaDetailsRestTimeViewController.fromStoryboard()
    private let infoViewController = ArenaDetailsInfoViewController.fromStoryboard()
    private let meetupTimeViewController = ArenaDetailsMeetupTimeViewController.fromStoryboard()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
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
        meetupTimeViewController.view.isHidden = viewModel.isRaidExpired
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
            restTimeViewController.updateTimeLeft(timeLeft)
        case .hatchTimeLeftChanged(let timeLeft):
            restTimeViewController.updateHatchTimeLeft(timeLeft)
        }
    }
}