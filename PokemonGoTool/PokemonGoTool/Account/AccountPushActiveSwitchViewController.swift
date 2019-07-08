
import UIKit

class AccountPushActiveSwitchViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: AccountViewModel!

    @IBOutlet var titleLabel: Label!
    @IBOutlet var pushActiveSwitch: UISwitch!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pushActiveSwitch.isOn = viewModel.isPushActivated
    }
    
    @IBAction func pushActiveSwitchDidChange(_ sender: UISwitch) {
        viewModel.pushActivatedChanged(sender.isOn)
    }
}
