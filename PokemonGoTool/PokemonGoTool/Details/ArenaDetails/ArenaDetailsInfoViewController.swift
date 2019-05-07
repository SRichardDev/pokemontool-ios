
import UIKit

class ArenaDetailsInfoViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: ArenaDetailsViewModel!
    @IBOutlet var coordinateTitleLabel: Label!
    @IBOutlet var coordinateLabel: Label!
    @IBOutlet var submitterTitleLabel: Label!
    @IBOutlet var submitterLabel: Label!
    @IBOutlet var goldArenaSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinateLabel.text = "\(viewModel.arena.latitude), \(viewModel.arena.longitude)"
        viewModel.submitterName { self.submitterLabel.text = $0 }
        goldArenaSwitch.isOn = viewModel.isGoldArena
    }
    
    @IBAction func goldArenaSwitchChanged(_ sender: UISwitch) {
        viewModel.changeGoldArena(isGold: sender.isOn)
    }
}
