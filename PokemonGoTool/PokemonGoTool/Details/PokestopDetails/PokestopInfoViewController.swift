
import UIKit

class PokestopInfoViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: PokestopDetailsViewModel!

    @IBOutlet var coordinateTitleLabel: Label!
    @IBOutlet var coordianteLabel: Label!
    @IBOutlet var submitterTitleLabel: Label!
    @IBOutlet var submitterLabel: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinateTitleLabel.text = "Koordinaten:"
        submitterTitleLabel.text = "Hinzugefügt von:"
        
        coordianteLabel.text = "\(viewModel.coordinate.latitude), \(viewModel.coordinate.longitude)"
        viewModel.pokestopSubmitterName(completion: { self.submitterLabel.text = $0 })
    }
}
