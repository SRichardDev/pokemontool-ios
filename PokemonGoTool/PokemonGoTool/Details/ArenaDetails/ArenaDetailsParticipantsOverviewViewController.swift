
import UIKit

class ArenaDetailsParticipantsOverviewViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: ArenaDetailsViewModel!
    weak var coordinator: MainCoordinator?
    @IBOutlet var titleLabel: Label!
    @IBOutlet var participantsCountLabel: Label!
    @IBOutlet var participantsListButton: Button!
    @IBOutlet var participateButton: Button!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    func updateUI() {
        participantsCountLabel.text = "\(viewModel.participants.count)"
        participateButton.isDestructive = viewModel.isUserParticipating
        participateButton.setTitle(viewModel.participateButtonTitle, for: .normal)
    }

    @IBAction func showParticipantsList(_ sender: Any) {
        coordinator?.showRaidParticipants(viewModel)
    }


    @IBAction func participateTapped(_ sender: Button) {
        viewModel.userTappedParticipate()
        updateUI()
    }
}
