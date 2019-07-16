
import UIKit

class SubmitRaidViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: SubmitRaidViewModel!

    @IBOutlet var disclaimerLabel: Label!
    @IBOutlet var submitButton: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        disclaimerLabel.text = "Bitte überprüfe deine Eingaben auf Richtigkeit bevor du den Raid meldest. Bitte mache keine falschen Angaben, da andere Spieler via Push Nachrichten über diesen Raid benachrichtigt werden. Missbrauch kann zur Löschung deines Accounts führen!"
        
        submitButton.setTitle("Raid melden", for: .normal)
        submitButton.addAction {
            self.viewModel.submitRaid()
        }
    }
}
