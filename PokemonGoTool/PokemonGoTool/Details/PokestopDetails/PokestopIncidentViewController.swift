
import UIKit

class PokestopIncidentViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: PokestopDetailsViewModel!
    
    @IBOutlet var incidentTitleLabel: Label!
    @IBOutlet var incidentLabel: Label!
    @IBOutlet var timeFrameTitleLabel: Label!
    @IBOutlet var timeFrameLabel: Label!
    @IBOutlet var submitterTitleLabel: Label!
    @IBOutlet var submitterLabel: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        incidentLabel.text = viewModel.incidentName
        timeFrameLabel.text = viewModel.incidentTimeFrame
        submitterLabel.text = viewModel.incidentSubmitter
    }
}
