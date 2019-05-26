
import UIKit

extension UIStackView {
    
    func addArrangedViewController(viewController: UIViewController, to parent: UIViewController) {
        viewController.view.backgroundColor = .clear
        parent.addChild(viewController)
        addArrangedSubview(viewController.view)
        viewController.didMove(toParent: parent)
    }
    
    func addSepartor() {
        let separatorView = SeparatorView.fromNib()
        addArrangedSubview(separatorView)
    }
}
