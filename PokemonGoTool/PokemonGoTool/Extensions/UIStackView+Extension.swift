
import UIKit

extension UIStackView {
    func addArrangedViewController(viewController: UIViewController, to parent: UIViewController) {
        parent.addChild(viewController)
        addArrangedSubview(viewController.view)
        viewController.didMove(toParent: parent)
    }
}
