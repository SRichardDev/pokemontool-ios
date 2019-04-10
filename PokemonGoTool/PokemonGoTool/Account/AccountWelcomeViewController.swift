
import UIKit

class AccountWelcomeViewController: UIViewController, StoryboardInitialViewController {

    @IBOutlet var topImageView: UIImageView!
    @IBOutlet var leftImageView: UIImageView!
    @IBOutlet var rightImageView: UIImageView!
    @IBOutlet var titleLabel: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Lege einen Account an oder melde dich an, um den vollen Umfang der App zu benutzen"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let imageViews = [topImageView, leftImageView, rightImageView].shuffled()
        imageViews[0]?.image = UIImage(named: "mystic")
        imageViews[1]?.image = UIImage(named: "valor")
        imageViews[2]?.image = UIImage(named: "instinct")
    }
}
