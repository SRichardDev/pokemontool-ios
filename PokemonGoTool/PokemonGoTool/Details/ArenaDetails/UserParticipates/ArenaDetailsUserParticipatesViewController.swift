
import UIKit

class ArenaDetailsUserParticipatesViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: ArenaDetailsViewModel!
    
    @IBOutlet var titleLabel: Label!
    @IBOutlet var switchControl: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Teilnehmen:"
        updateUI()
    }
    
    func updateUI() {
        guard switchControl != nil else { return }
        switchControl.isOn = viewModel.isUserParticipating
    }
    
    @IBAction func switchToggled(_ sender: UISwitch) {
        viewModel.userParticipates(sender.isOn)
    }
}
