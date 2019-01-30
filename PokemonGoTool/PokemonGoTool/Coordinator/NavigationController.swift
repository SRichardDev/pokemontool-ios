
import UIKit

class NavigationController: UINavigationController {

    private var cancelBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissSelf))
        navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topViewController?.navigationItem.rightBarButtonItem = cancelBarButtonItem
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        viewController.navigationItem.rightBarButtonItem = cancelBarButtonItem
    }
    
    @objc
    func dismissSelf() {
        dismiss(animated: true)
    }
}
