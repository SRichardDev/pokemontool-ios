
import UIKit
import NVActivityIndicatorView

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
    
    func changeVisibiltyOf(viewControllers: [UIViewController]) {
        
        var viewControllersToShow = [UIViewController]()
        var viewControllersToHide = [UIViewController]()
        
        for viewController in viewControllers {
            viewController.view.isHidden ? viewControllersToShow.append(viewController) : viewControllersToHide.append(viewController)
        }
        
        viewControllersToHide.forEach { vcToHide in
            UIView.animate(withDuration: 0.25, animations: {
                vcToHide.view.alpha = 0
            }, completion: { _ in
                UIView.animate(withDuration: 0.25, animations: {
                    vcToHide.view.isHidden = true
                }, completion: { _ in
                    viewControllersToShow.forEach { vcToShow in
                        UIView.animate(withDuration: 0.25, animations: {
                            vcToShow.view.alpha = 1
                        }, completion: { _ in
                            UIView.animate(withDuration: 0.25, animations: {
                                vcToShow.view.isHidden = false
                            })
                        })
                    }
                })
            })
        }
    }
    
    func changeVisibility(of viewController: UIViewController, visible: Bool, hideAnimated: Bool = true) {
        
        UIView.animate(withDuration: 0.25, animations: {
            viewController.view.alpha = visible ? 1 : 0
        }) { done in
            if hideAnimated {
                UIView.animate(withDuration: 0.25) {
                    viewController.view.isHidden = !visible
                }
            } else {
                viewController.view.isHidden = !visible
            }
        }
    }
}

var vSpinner : UIView?

extension UIViewController {
    func showSpinner() {
        
        guard let window = UIApplication.shared.keyWindow else { return }
        
        let activityIndicator = NVActivityIndicatorView(frame: window.bounds, type: .ballTrianglePath, color: .black, padding: 50)
        activityIndicator.startAnimating()
        let spinnerView = UIView(frame: window.bounds)
        let blurEffect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(frame: window.bounds)
        effectView.effect = blurEffect
        spinnerView.addSubview(effectView)
        spinnerView.alpha = 0
        
        DispatchQueue.main.async {
            spinnerView.addSubview(activityIndicator)
            window.addSubview(spinnerView)
            
            UIView.animate(withDuration: 0.25, animations: {
                spinnerView.alpha = 1
            })
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, animations: {
                vSpinner?.alpha = 0
            }, completion: { _ in
                vSpinner?.removeFromSuperview()
                vSpinner = nil
            })
        }
    }
}
