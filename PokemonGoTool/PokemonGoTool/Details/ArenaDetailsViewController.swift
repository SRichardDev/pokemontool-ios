
import UIKit

class ArenaDetailsViewController: UIViewController, StoryboardInitialViewController {
    
    weak var coordinator: MainCoordinator?
    var viewModel: ArenaDetailsViewModel!
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let titleLabel = Label()
    private let headerViewController = ArenaDetailsHeaderViewController.instantiateFromStoryboard()
    private let participantsTableViewController = ArenaDetailsActiveRaidParticipantsTableViewController.instantiateFromStoryboard()
    private let restTimeViewController = ArenaDetailsActiveRaidRestTimeViewController.instantiateFromStoryboard()
    private let participateButton = Button()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        titleLabel.style = 3
        
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
        titleLabel.text = viewModel.isRaidExpired ? viewModel.arena.name : viewModel.arena.raid?.raidBoss?.name
    }
    
    @objc
    func participateTapped() {
        viewModel.userParticipates()
    }
}
