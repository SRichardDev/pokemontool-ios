
import UIKit

class ArenaDetailsRestTimeViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: ArenaDetailsViewModel!

    @IBOutlet weak var titleLabel: Label!
    @IBOutlet var restTimeLabel: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restTimeLabel.text = "--:--:--"
    }

    func updateTimeLeft(_ string: String) {
        titleLabel.text = "Zeit bis Raid endet:"
        restTimeLabel.text = string
    }
    
    func updateHatchTimeLeft(_ string: String) {
        titleLabel.text = "Zeit bis Ei schlüpft:"
        restTimeLabel.text = string
    }
}
