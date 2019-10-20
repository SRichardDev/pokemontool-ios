
import UIKit

class ArenaDetailsRestTimeViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: ArenaDetailsViewModel!

    @IBOutlet var titleLabel: Label!
    @IBOutlet var restTimeLabel: Label!
    @IBOutlet var pointOfTimeLabel: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restTimeLabel.text = "--:--"
    }

    func updateTimeLeft(_ string: String) {
        titleLabel.text = "Zeit bis Raid endet:"
        restTimeLabel.text = string
//        pointOfTimeLabel.text = viewModel.endTime
    }
    
    func updateHatchTimeLeft(_ string: String) {
        titleLabel.text = "Zeit bis Ei schlüpft:"
        restTimeLabel.text = string
//        pointOfTimeLabel.text = viewModel.hatchTime
    }
}
