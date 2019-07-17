
import UIKit

class ButtonsStackViewController: UIViewController, StoryboardInitialViewController {
    
    @IBOutlet var stackView: UIStackView!
    var buttons: [UIButton]!
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.layer.borderColor = UIColor.lightGray.cgColor
        if UIDevice.current.orientation.isLandscape {
            view.layer.cornerRadius = stackView.frame.size.height / 2
        } else {
            view.layer.cornerRadius = stackView.frame.size.width / 2
        }
        view.layer.borderWidth = 1
        view.clipsToBounds = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            stackView.axis = .horizontal
        } else {
            stackView.axis = .vertical
        }
        view.layoutSubviews()
    }
    
    func toggleVisibilty() {
        let animator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 5) {
            self.buttons.forEach {
                let pulse = CASpringAnimation(keyPath: "transform.scale")
                pulse.duration = 0.25
                pulse.fromValue = $0.isHidden ? 0 : 1
                pulse.toValue = $0.isHidden ? 1 : 0
                $0.layer.add(pulse, forKey: "pulse")
                $0.isHidden = !$0.isHidden
                $0.alpha = $0.isHidden ? 0 : 1
            }
        }
        animator.startAnimation()
        
        let feedback = UISelectionFeedbackGenerator()
        feedback.prepare()
        feedback.selectionChanged()
    }
    
    @discardableResult
    class func embed(in containerView: UIView,
                     in viewController: UIViewController,
                     with buttons: [UIButton]) -> ButtonsStackViewController {
        
        let buttonsStackViewController = ButtonsStackViewController.fromStoryboard()
        buttonsStackViewController.loadView()
        buttons.forEach({$0.tintColor = .black})
        buttonsStackViewController.buttons = buttons
        
        buttons.forEach {
            buttonsStackViewController.stackView.addArrangedSubview($0)
            $0.widthAnchor.constraint(equalToConstant: 50).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            $0.showsTouchWhenHighlighted = true
            $0.isHidden = true
        }
        
        let settingsButton = UIButton()
        settingsButton.setImage(UIImage(named: "mapMenuGear"), for: .normal)
        settingsButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        settingsButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        settingsButton.addAction {
            buttonsStackViewController.toggleVisibilty()
            let spring = CASpringAnimation(keyPath: "transform.scale")
            spring.damping = 30.0
            spring.fromValue = 1
            spring.toValue = 1.2
            spring.duration = 0.125
            spring.autoreverses = true
            settingsButton.layer.add(spring, forKey: "scale")
        }
        buttonsStackViewController.stackView.addArrangedSubview(settingsButton)

        viewController.add(buttonsStackViewController, toView: containerView)
        containerView.addSubviewAndEdgeConstraints(buttonsStackViewController.view)
        containerView.addShadow()
        containerView.clipsToBounds = false
        return buttonsStackViewController
    }
}
