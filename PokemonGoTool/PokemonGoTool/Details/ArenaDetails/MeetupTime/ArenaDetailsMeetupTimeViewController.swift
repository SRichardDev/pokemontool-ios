
import UIKit

class ArenaDetailsMeetupTimeViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: ArenaDetailsViewModel!
    
    @IBOutlet var titleLabel: Label!
    @IBOutlet var meetupTimeLabel: Label!
    @IBOutlet var changeMeetupTimeButton: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Treffpunkt:"
        changeMeetupTimeButton.setTitle("Treffpunkt ändern", for: .normal)
    }
    
    func updateUI() {
        meetupTimeLabel.text = viewModel.meetup?.meetupTime
    }
    
    @IBAction func didTapChangeMeetupTime(_ sender: Any) {
        viewModel.changeMeetupTimeRequested()
    }
}
