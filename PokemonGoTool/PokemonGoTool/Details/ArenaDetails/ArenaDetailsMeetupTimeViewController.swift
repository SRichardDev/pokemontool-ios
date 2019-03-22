
import UIKit

class ArenaDetailsMeetupTimeViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: ArenaDetailsViewModel!
    
    @IBOutlet var titleLabel: Label!
    @IBOutlet var meetupTimeLabel: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateUI() {
        meetupTimeLabel.text = viewModel.meetup?.meetupTime ?? "Kein Treffpunkt gesetzt"
    }
}
