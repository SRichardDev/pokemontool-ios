
import UIKit

protocol BottomMenuShowable {}

extension BottomMenuShowable where Self: UIViewController {
    
    @discardableResult
    func showBottomMenu(_ buttons: [UIButton]) -> UIView {
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 40
        stackView.alpha = 0
        view.addSubview(stackView)
        
        view.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 25).isActive = true
        
        UIView.animate(withDuration: 0.25, animations: { stackView.alpha = 1 })
        return stackView
    }
}
