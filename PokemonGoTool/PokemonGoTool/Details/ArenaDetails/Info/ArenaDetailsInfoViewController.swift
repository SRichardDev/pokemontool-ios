
import UIKit

class ArenaDetailsInfoViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: ArenaDetailsViewModel!
    @IBOutlet var coordinateTitleLabel: Label!
    @IBOutlet var coordinateLabel: Label!
    @IBOutlet var raidSubmitterTitleLabel: Label!
    @IBOutlet var raidSubmitterLabel: Label!
    @IBOutlet var submitterTitleLabel: Label!
    @IBOutlet var submitterLabel: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinateTitleLabel.text = "Koordinaten:"
        raidSubmitterTitleLabel.text = "Raid gemeldet von:"
        submitterTitleLabel.text = "Arena hinzugefügt von:"
        coordinateLabel.text = "\(viewModel.arena.latitude), \(viewModel.arena.longitude)"
        viewModel.submitterName { self.submitterLabel.text = $0 }
        viewModel.submitterNameForRaid { self.raidSubmitterLabel.text = $0 }
    }
}
