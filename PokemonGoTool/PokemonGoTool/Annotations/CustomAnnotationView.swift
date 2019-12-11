
import UIKit
import MapKit

class CustomAnnotationView: MKAnnotationView {

    var customCalloutView: UIView?
    var label = UILabel()
    var labelOffsetY: CGFloat = 28
    
    override func didMoveToSuperview() {
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        label.backgroundColor = UIColor(white: 1, alpha: 0.7)
        label.numberOfLines = 0
        label.layer.cornerRadius = 2
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 0.5
        label.clipsToBounds = true
        let padding: CGFloat = 5
        label.frame = CGRect(x: -label.intrinsicContentSize.width/2 + frame.width/2 - padding/2,
                             y: frame.height - labelOffsetY,
                             width: label.intrinsicContentSize.width + padding,
                             height: label.intrinsicContentSize.height)
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        canShowCallout = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        canShowCallout = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        image = nil
        label.alpha = 0
        label.removeFromSuperview()
        customCalloutView?.removeFromSuperview()
        subviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    func changeLabelVisibilityAnimated(_ visible: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.label.alpha = visible ? 1 : 0
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if (hitView != nil) {
            self.superview?.bringSubviewToFront(self)
        }
        return hitView
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds
        var isInside: Bool = rect.contains(point)
        if(!isInside) {
            for view in self.subviews {
                isInside = view.frame.contains(point)
                if isInside {
                    break
                }
            }
        }
        return isInside
    }
}

