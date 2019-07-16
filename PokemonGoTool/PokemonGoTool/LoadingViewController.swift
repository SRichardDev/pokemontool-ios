
import UIKit
import NVActivityIndicatorView

class LoadingViewController: UIViewController, StoryboardInitialViewController, NVActivityIndicatorViewable {

    @IBOutlet var activityIndicator: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        view.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    }
}
