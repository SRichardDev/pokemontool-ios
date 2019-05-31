
import UIKit

class ArenaDetailsGoldArenaSwitchViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: ArenaDetailsViewModel!
    @IBOutlet var titleLabel: Label!
    @IBOutlet var goldArenaSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Gold Arena:"
        goldArenaSwitch.isOn = viewModel.isGoldArena
    }
    
    @IBAction func goldArenaSwitchChanged(_ sender: UISwitch) {
        viewModel.changeGoldArena(isGold: sender.isOn)
    }
}
