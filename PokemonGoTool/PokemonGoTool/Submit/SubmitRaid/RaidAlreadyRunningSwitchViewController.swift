
import UIKit

class RaidAlreadyRunningSwitchViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: SubmitRaidViewModel!
    @IBOutlet var titleLabel: Label!
    @IBOutlet var switchControl: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func switchToggled(_ sender: UISwitch) {
        viewModel.raidAlreadyRunning(sender.isOn)
    }
}
