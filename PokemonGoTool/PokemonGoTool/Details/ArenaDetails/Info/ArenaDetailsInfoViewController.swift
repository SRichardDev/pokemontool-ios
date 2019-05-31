
import UIKit

class ArenaDetailsInfoViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: ArenaDetailsViewModel!
    @IBOutlet var coordinateTitleLabel: Label!
    @IBOutlet var coordinateLabel: Label!
    @IBOutlet var submitterTitleLabel: Label!
    @IBOutlet var submitterLabel: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinateTitleLabel.text = "Koordinaten:"
        submitterTitleLabel.text = "Hinzugefügt von:"
        coordinateLabel.text = "\(viewModel.arena.latitude), \(viewModel.arena.longitude)"
        viewModel.submitterName { self.submitterLabel.text = $0 }
    }
}
