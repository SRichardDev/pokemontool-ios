
import UIKit

class ArenaDetailsInfoViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: ArenaDetailsViewModel!
    @IBOutlet var coordinateTitleLabel: Label!
    @IBOutlet var coordinateLabel: Label!
    @IBOutlet var submitterTitleLabel: Label!
    @IBOutlet var submitterLabel: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinateLabel.text = "\(viewModel.arena.latitude), \(viewModel.arena.longitude)"
        submitterLabel.text = viewModel.arena.submitter
    }
}
