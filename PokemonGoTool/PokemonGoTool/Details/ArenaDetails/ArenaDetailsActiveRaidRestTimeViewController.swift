
import UIKit

class ArenaDetailsActiveRaidRestTimeViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: ArenaDetailsViewModel!

    @IBOutlet var restTimeLabel: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restTimeLabel.text = "\n-- : -- : --"
    }

    func updateTime(_ string: String?) {
        restTimeLabel.text = string
    }
}
