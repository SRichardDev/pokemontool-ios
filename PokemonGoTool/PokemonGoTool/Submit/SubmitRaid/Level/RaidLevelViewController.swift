
import UIKit

class RaidLevelViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: SubmitRaidViewModel!
    @IBOutlet var titleLabel: Label!
    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        changeButtonSelection()
    }
    
    @IBAction func levelButtonsTapped(_ sender: UIButton) {
        viewModel.selectedRaidLevel = sender.tag
        viewModel.raidLevelChanged(to: sender.tag)
        changeButtonSelection()
    }
    
    private func changeButtonSelection() {
        buttons.forEach {
            $0.layer.borderColor = UIColor.clear.cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 5
        }
        buttons[viewModel.selectedRaidLevel - 1].layer.borderColor = UIColor.lightGray.cgColor
    }
}
