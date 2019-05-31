
import UIKit

class RaidUserParticipateSwitchViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: SubmitRaidViewModel!
    @IBOutlet var titleLabel: Label!
    @IBOutlet var switchControl: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Nimmst du teil am Raid?"
        switchControl.isOn = viewModel.isUserParticipating
    }
    
    @IBAction func switchToggled(_ sender: UISwitch) {
        viewModel.userParticipates(sender.isOn)
    }
}
