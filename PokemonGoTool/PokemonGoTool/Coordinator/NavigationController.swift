
import UIKit

class NavigationController: UINavigationController {

    var isDismissable = true
    private var cancelBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isDismissable {
            let button = UIButton(type: .custom)
            button.addAction { [weak self] in
                self?.dismiss(animated: true)
            }
            button.setImage(UIImage(named: "dismiss"), for: .normal)
            let item = UIBarButtonItem(customView: button)
            topViewController?.navigationItem.leftBarButtonItem = item
        }
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        if isDismissable {
            viewController.navigationItem.rightBarButtonItem = cancelBarButtonItem
        }
    }
}
