
import UIKit

class ButtonsStackViewController: UIViewController, StoryboardInitialViewController {
    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var buttons: [UIButton]!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = stackView.frame.size.width / 2
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        
        buttons.forEach {
            $0.isHidden = true
        }
    }
    
    @IBAction func toggleVisibilty() {
        let animator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 5) {
            self.buttons.forEach {
                $0.isHidden = !$0.isHidden
                $0.alpha = $0.isHidden ? 0 : 1
            }
        }
        animator.startAnimation()
        
        let feedback = UISelectionFeedbackGenerator()
        feedback.prepare()
        feedback.selectionChanged()
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
    
    }
    
    @discardableResult
    class func embed(in containerView: UIView, in viewController: UIViewController) -> ButtonsStackViewController {
        let buttonsStackViewController = ButtonsStackViewController.instantiateFromStoryboard()
        viewController.add(buttonsStackViewController, toView: containerView)
        containerView.addSubviewAndEdgeConstraints(buttonsStackViewController.view)
        return buttonsStackViewController
    }
}
