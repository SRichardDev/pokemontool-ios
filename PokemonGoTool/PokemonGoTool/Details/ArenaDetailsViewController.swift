
import UIKit

class ArenaDetailsViewController: UIViewController, StoryboardInitialViewController {
    
    weak var coordinator: MainCoordinator?
    var viewModel: ArenaDetailsViewModel!
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    let participantsTableView = ArenaDetailsActiveRaidParticipantsTableViewController.instantiateFromStoryboard()
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
        
        imageView.image = viewModel.image
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        let bossNameLabel = Label()
        bossNameLabel.style = 3
        bossNameLabel.text = viewModel.arena.raid?.raidBoss?.name

        
        participateButton.setTitle("Teilnehmen", for: .normal)
        participateButton.addTarget(self, action: #selector(participateTapped), for: .touchUpInside)

        participantsTableView.viewModel = viewModel
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(bossNameLabel)
        stackView.addArrangedViewController(viewController: participantsTableView, to: self)
        stackView.addArrangedSubview(participateButton)
    }
    
    @objc
    func participateTapped() {
        viewModel.userParticipates()
    }
}
