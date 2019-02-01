
import UIKit

protocol SwitchDelegate: class {
    func didToggleSwitch(enabled: Bool)
}

class RaidLabelSwitchViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: SubmitRaidViewModel!
    weak var delegate: SwitchDelegate?
    @IBOutlet var titleLabel: Label!
    @IBOutlet var switchControl: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func switchToggled(_ sender: UISwitch) {
        viewModel.switchToggled(enabled: sender.isOn)
    }
}
