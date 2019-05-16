
import UIKit

class ArenaDetailsParticipantsOverviewViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: ArenaDetailsViewModel!
    weak var coordinator: MainCoordinator?
    @IBOutlet var titleLabel: Label!
    @IBOutlet var participantsCountLabel: Label!
    @IBOutlet var participantsListButton: Button!
    @IBOutlet var participateTitleLabel: Label!
    @IBOutlet var participateSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        participateTitleLabel.text = "Teilnehmen:"
        updateUI()
    }

    func updateUI() {
        participantsCountLabel.text = "\(viewModel.participants.count)"
        participateSwitch.isOn = viewModel.isUserParticipating
    }

    @IBAction func showParticipantsList(_ sender: Any) {
        coordinator?.showRaidParticipants(viewModel)
    }

    @IBAction func participateSwitchChanged(_ sender: UISwitch) {
        viewModel.userParticipates(sender.isOn)
    }

    @IBAction func showChat(_ sender: Any) {
        coordinator?.showRaidChat(viewModel)
    }
}
