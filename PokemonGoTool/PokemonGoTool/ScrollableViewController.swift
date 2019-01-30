import UIKit

class ScrollableViewController: UIViewController {
    
    var scrollView = UIScrollView()
    var childViewController: UIViewController! {
        willSet {
            childViewController?.willMove(toParent: nil)
            childViewController?.removeFromParent()
            childViewController?.view.removeFromSuperview()
        }
        didSet {
            embedChildViewController()
        }
    }
    
    public init(childViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        self.childViewController = childViewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func loadView() {
        self.view = scrollView
        scrollView.backgroundColor = .white
        embedChildViewController()
    }
    
    private func embedChildViewController() {
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubviewAndEdgeConstraints(childViewController.view)
        childViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        addChild(childViewController)
        childViewController.didMove(toParent: self)
    }
}
