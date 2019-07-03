
import UIKit

class AccountWelcomeViewController: UIViewController, StoryboardInitialViewController {

    weak var coordinator: MainCoordinator?
    @IBOutlet var topImageView: UIImageView!
    @IBOutlet var leftImageView: UIImageView!
    @IBOutlet var rightImageView: UIImageView!
    @IBOutlet var titleLabel: Label!
    @IBOutlet var loginButton: Button!
    @IBOutlet var signupButton: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Lege einen Account an oder melde dich an, um den vollen Umfang der App zu benutzen"
        
        
        signupButton.setTitle("Account anlegen", for: .normal)
        signupButton.addAction(for: .touchUpInside) { [unowned self] in
            self.coordinator?.showAccountInput(type: .email)
        }
        
        loginButton.setTitle("Anmelden", for: .normal)
        loginButton.addAction(for: .touchUpInside) { [unowned self] in
            self.coordinator?.showAccountInput(type: .emailSignIn)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let imageViews = [topImageView, leftImageView, rightImageView].shuffled()
        imageViews[0]?.image = UIImage(named: "mystic")
        imageViews[1]?.image = UIImage(named: "valor")
        imageViews[2]?.image = UIImage(named: "instinct")
    }
}
