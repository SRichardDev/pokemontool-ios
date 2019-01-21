
import UIKit

class SubmitQuestViewController: UIViewController, StoryboardInitialViewController {
    
    var pokestop: Pokestop!
    var firebaseConnector: FirebaseConnector!
    @IBOutlet var questNameTextField: UITextField!
    @IBOutlet var rewardTextField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        questNameTextField.text = pokestop.quest?.name
        rewardTextField.text = pokestop.quest?.reward
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        let quest = Quest(name: questNameTextField.text!, reward: rewardTextField.text!, submitter: "Foo")
        firebaseConnector.saveQuest(quest: quest, for: pokestop)
        dismiss(animated: true)
    }
}
