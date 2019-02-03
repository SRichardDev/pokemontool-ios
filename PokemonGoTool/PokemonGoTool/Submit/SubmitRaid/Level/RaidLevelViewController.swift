
import UIKit

class RaidLevelViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: SubmitRaidViewModel!
    @IBOutlet var titleLabel: Label!
    @IBOutlet var buttons: [UIButton]!
    
    @IBAction func levelButtonsTapped(_ sender: UIButton) {
        buttons.forEach {
            $0.layer.borderColor = UIColor.clear.cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 5
        }
        sender.layer.borderColor = UIColor.lightGray.cgColor
       
        viewModel.raidLevelChanged(to: sender.tag)
    }
}
