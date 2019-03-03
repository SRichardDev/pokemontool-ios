
import UIKit

class ArenaDetailsViewController: UIViewController, StoryboardInitialViewController, ArenaDetailsDelegate {
    
    weak var coordinator: MainCoordinator?
    var viewModel: ArenaDetailsViewModel!
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let headerViewController = ArenaDetailsHeaderViewController.instantiateFromStoryboard()
    private let participantsTableViewController = ArenaDetailsActiveRaidParticipantsTableViewController.instantiateFromStoryboard()
    private let restTimeViewController = ArenaDetailsActiveRaidRestTimeViewController.instantiateFromStoryboard()
    private let participateButton = Button()
    
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
        
        participateButton.setTitle("Teilnehmen", for: .normal)
        participateButton.addTarget(self, action: #selector(participateTapped), for: .touchUpInside)

        headerViewController.viewModel = viewModel
        restTimeViewController.viewModel = viewModel
        participantsTableViewController.viewModel = viewModel

        stackView.addArrangedViewController(viewController: headerViewController, to: self)
        stackView.addSepartor()
        stackView.addArrangedViewController(viewController: restTimeViewController, to: self)
        stackView.addSepartor()
        stackView.addArrangedViewController(viewController: participantsTableViewController, to: self)
        stackView.addArrangedSubview(participateButton)
        
        restTimeViewController.view.isHidden = viewModel.isRaidExpired
        participantsTableViewController.view.isHidden = viewModel.isRaidExpired
        participateButton.isHidden = viewModel.isRaidExpired

    }
    
    func updateUI() {
        restTimeViewController.view.isHidden = viewModel.isRaidExpired
        participateButton.isHidden = viewModel.isRaidExpired
    }
    
    var animating = false
    func update(of type: ArenaDetailsUpdateType) {
        updateUI()
        switch type {
        case .usersChanged:
            participantsTableViewController.updateUI()
            
        case .timeLeftChanged(let timeLeft):
            restTimeViewController.updateTime(timeLeft)
        }
    }
    
    @objc
    func participateTapped() {
        viewModel.userParticipates()
    }
}
