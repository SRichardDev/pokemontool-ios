
import UIKit

extension UIStackView {
    
    func addArrangedViewController(_ viewController: UIViewController, to parent: UIViewController) {
        viewController.view.backgroundColor = .clear
        parent.addChild(viewController)
        addArrangedSubview(viewController.view)
        viewController.didMove(toParent: parent)
    }
}
