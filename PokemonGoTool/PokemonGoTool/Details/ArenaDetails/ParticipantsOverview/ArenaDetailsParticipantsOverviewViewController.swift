
import UIKit

class ArenaDetailsParticipantsOverviewViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: ArenaDetailsViewModel!
    weak var coordinator: MainCoordinator?
    @IBOutlet var titleLabel: Label!
    @IBOutlet var participantsCountLabel: Label!
    @IBOutlet var participantsListButton: Button!

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Anzahl der Teilnehmer:"
        updateUI()
    }

    func updateUI() {
        participantsCountLabel.text = "\(viewModel.participants.count)"
    }

    @IBAction func showParticipantsList(_ sender: Any) {
        coordinator?.showRaidParticipants(viewModel)
    }

    @IBAction func showChat(_ sender: Any) {
        coordinator?.showRaidChat(viewModel)
    }
}
