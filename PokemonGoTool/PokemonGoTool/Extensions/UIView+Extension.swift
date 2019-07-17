
import UIKit

extension UIView {
    
    var isVisible: Bool {
        get {
            return !isHidden
        }
        set {
            isHidden = !newValue
        }
    }
    
    public func addSubviewAndEdgeConstraints(_ subview: UIView, edges: UIRectEdge = .all, margins: UIEdgeInsets = .zero, constrainToSafeAreaGuide: Bool = false) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        addEdgeConstraints(for: subview, edges: edges, margins: margins, constrainToSafeAreaGuide: constrainToSafeAreaGuide)
    }
    
    public func insertSubviewAndEdgeConstraints(_ subview: UIView, at index: Int, edges: UIRectEdge = .all, margins: UIEdgeInsets = .zero, constrainToSafeAreaGuide: Bool = false) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(subview, at: index)
        addEdgeConstraints(for: subview, edges: edges, margins: margins, constrainToSafeAreaGuide: constrainToSafeAreaGuide)
    }
    
    public func addEdgeConstraints(for subview: UIView, edges: UIRectEdge = .all, margins: UIEdgeInsets = .zero, constrainToSafeAreaGuide: Bool = false) {
        
        if edges.contains(.top) {
            if #available(iOS 11.0, iOSApplicationExtension 11.0, *), constrainToSafeAreaGuide {
                subview.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: margins.top).isActive = true
            } else {
                subview.topAnchor.constraint(equalTo: topAnchor, constant: margins.top).isActive = true
            }
        }
        
        if edges.contains(.bottom) {
            if #available(iOS 11.0, iOSApplicationExtension 11.0, *), constrainToSafeAreaGuide {
                safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: subview.bottomAnchor, constant: margins.bottom).isActive = true
            } else {
                bottomAnchor.constraint(equalTo: subview.bottomAnchor, constant: margins.bottom).isActive = true
            }
            
        }
        
        if edges.contains(.left) {
            if #available(iOS 11.0, iOSApplicationExtension 11.0, *), constrainToSafeAreaGuide {
                subview.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: margins.left).isActive = true
            } else {
                subview.leftAnchor.constraint(equalTo: leftAnchor, constant: margins.left).isActive = true
            }
        }
        
        if edges.contains(.right) {
            if #available(iOS 11.0, iOSApplicationExtension 11.0, *), constrainToSafeAreaGuide {
                safeAreaLayoutGuide.rightAnchor.constraint(equalTo: subview.rightAnchor, constant: margins.right).isActive = true
            } else {
                rightAnchor.constraint(equalTo: subview.rightAnchor, constant: margins.right).isActive = true
            }
        }
    }
}

extension UIView {
    enum AnimationKeyPath: String {
        case opacity = "opacity"
    }
    
    func flash(animation: AnimationKeyPath ,withDuration duration: TimeInterval = 1){
        let flash = CABasicAnimation(keyPath:AnimationKeyPath.opacity.rawValue)
        flash.duration = duration
        flash.fromValue = 1
        flash.toValue = 0.3
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = Float.greatestFiniteMagnitude
        flash.isRemovedOnCompletion = false
        layer.add(flash, forKey: nil)
    }
}

extension UIView {
    func addShadow() {
        layer.shadowColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 0.2
    }
}
