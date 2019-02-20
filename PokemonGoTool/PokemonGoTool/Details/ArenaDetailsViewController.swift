
import UIKit

class ArenaDetailsViewController: UIViewController, StoryboardInitialViewController {
    
    weak var coordinator: MainCoordinator?
    var viewModel: ArenaDetailsViewModel!
    private let stackView = UIStackView()

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
        let activeRaidViewController = ArenaDetailsActiveRaidViewController.instantiateFromStoryboard()
        activeRaidViewController.viewModel = viewModel
        stackView.addArrangedViewController(viewController: activeRaidViewController, to: self)
    }
}
