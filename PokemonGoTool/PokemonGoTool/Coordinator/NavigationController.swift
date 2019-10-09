
import UIKit

class NavigationController: UINavigationController {

    var isDismissable = true
    private var cancelBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.prefersLargeTitles = true
        
//        navigationBar.layer.masksToBounds = false
//        navigationBar.layer.shadowColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
//        navigationBar.layer.shadowOpacity = 0.5
//        navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2)
//        navigationBar.layer.shadowRadius = 0.2
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
