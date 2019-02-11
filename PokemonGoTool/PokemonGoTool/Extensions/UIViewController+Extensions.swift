
import UIKit

extension UIViewController {
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func add(_ child: UIViewController, toView: UIView) {
        addChild(child)
        toView.addSubview(child.view)
        child.didMove(toParent: self)
    }
        
    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
    
    func setTitle(_ title: String) {
        navigationController?.navigationBar.topItem?.title = title
    }
}
