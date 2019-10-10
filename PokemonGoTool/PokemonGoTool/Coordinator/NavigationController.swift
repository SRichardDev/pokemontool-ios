
import UIKit

class NavigationController: UINavigationController {

    var isDismissable = true
    private var cancelBarButtonItem: UIBarButtonItem!
    
    override var viewControllers: [UIViewController] {
        didSet {
            if isDismissable {
                let item = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
                topViewController?.navigationItem.rightBarButtonItem = item
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.prefersLargeTitles = true
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        if isDismissable {
            viewController.navigationItem.rightBarButtonItem = cancelBarButtonItem
        }
    }
    
    @objc
    func close() {
        dismiss(animated: true)
    }
}
