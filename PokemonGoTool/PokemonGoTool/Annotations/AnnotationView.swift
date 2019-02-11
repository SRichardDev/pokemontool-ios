
import UIKit
import MapKit

private let animationTime = 0.2

protocol DetailAnnotationViewDelegate: class {
    func showSubmitDetail(for annotation: Annotation)
    func showInfoDetail(for annotation: Annotation)
}

class AnnotationView: CustomAnnotationView {
    var customAnnotation: Annotation?
    weak var delegate: DetailAnnotationViewDelegate?
    
    override func didMoveToSuperview() {
        guard let annotation = customAnnotation else { return }
        
        if (customAnnotation as? Arena) != nil {
            labelOffsetY = 0
        } else {
            labelOffsetY = 28
        }
        
        label.text = annotation.name
        addSubview(label)
        super.didMoveToSuperview()
    }
    
    private func loadDetailAnnotationView() -> DetailAnnotationView? {
        guard let annotation = customAnnotation else { return nil }
        if let views = Bundle.main.loadNibNamed("DetailAnnotationView",
                                                owner: self,
                                                options: nil) as? [DetailAnnotationView], views.count > 0 {
            let detailAnnotationView = views.first!
            detailAnnotationView.configure(with: annotation)
            detailAnnotationView.delegate = delegate
            return detailAnnotationView
        }
        return nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.customCalloutView?.removeFromSuperview() // remove old custom callout (if any)
            
            if let newCustomCalloutView = loadDetailAnnotationView() {
                // fix location from top-left to its right place.
                newCustomCalloutView.frame.origin.x -= newCustomCalloutView.frame.width / 2.0 - (self.frame.width / 2.0)
                newCustomCalloutView.frame.origin.y -= newCustomCalloutView.frame.height
                
                // set custom callout view
                self.addSubview(newCustomCalloutView)
                self.customCalloutView = newCustomCalloutView
                
                // animate presentation
                if animated {
                    self.customCalloutView!.alpha = 0.0
                    UIView.animate(withDuration: animationTime, animations: {
                        self.customCalloutView!.alpha = 1.0
                    })
                }
            }
        } else {
            if customCalloutView != nil {
                if animated { // fade out animation, then remove it.
                    UIView.animate(withDuration: animationTime, animations: {
                        self.customCalloutView!.alpha = 0.0
                    }, completion: { (success) in
                        self.customCalloutView!.removeFromSuperview()
                    })
                } else {
                    self.customCalloutView!.removeFromSuperview()
                    
                }
            }
        }
    }
    
    class func prepareFor(mapView: MKMapView, annotation: MKAnnotation, showLabel: Bool = false) -> AnnotationView? {
        let reuseId = "annotationReuseIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)

        let pokestopAnnoation = annotation as? PokestopPointAnnotation
        let arenaAnnotation = annotation as? ArenaPointAnnotation

        if annotationView == nil {
            let pokestopAnnotationView = AnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pokestopAnnotationView.customAnnotation = pokestopAnnoation?.pokestop ?? arenaAnnotation?.arena
            pokestopAnnotationView.label.alpha = showLabel ? 1 : 0
            annotationView = pokestopAnnotationView

        } else {
            if let pokestopAnnotationView = annotationView as? AnnotationView {
                pokestopAnnotationView.annotation = annotation
                pokestopAnnotationView.label.alpha = showLabel ? 1 : 0
                pokestopAnnotationView.customAnnotation = pokestopAnnoation?.pokestop ?? arenaAnnotation?.arena
            }
        }
        annotationView?.image = UIImage(named: pokestopAnnoation?.imageName ?? arenaAnnotation?.imageName ?? "")
        return annotationView as? AnnotationView
    }
}
