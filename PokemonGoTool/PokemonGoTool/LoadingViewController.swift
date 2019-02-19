
import UIKit
import NVActivityIndicatorView

class LoadingViewController: UIViewController, StoryboardInitialViewController, NVActivityIndicatorViewable {

    @IBOutlet var activityIndicator: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
    }
}
