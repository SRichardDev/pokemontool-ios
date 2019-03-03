
import UIKit

class ArenaDetailsActiveRaidRestTimeViewController: UIViewController, StoryboardInitialViewController, RaidTimeLeftDelegate {
    
    var viewModel: ArenaDetailsViewModel!

    @IBOutlet var restTimeLabel: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restTimeLabel.text = "-- : -- : --"
        viewModel.delegate = self
    }

    func didUpdateTimeLeft(_ string: String) {
        restTimeLabel.text = string
    }
}
