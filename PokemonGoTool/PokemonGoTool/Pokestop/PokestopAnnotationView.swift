
import UIKit
import MapKit

private let animationTime = 0.25

protocol PokestopDetailDelegate: class {
    func showDetail(for pokestop: Pokestop)
}

class PokestopAnnotationView: CustomAnnotationView {
    var pokestop: Pokestop?
    weak var delegate: PokestopDetailDelegate?
    
    override func didMoveToSuperview() {
        guard let pokestop = pokestop else { return }
        label.text = pokestop.name
        addSubview(label)
        super.didMoveToSuperview()
    }
    
    func loadPokestopDetailAnnotationView() -> PokestopDetailAnnotationView? {
        guard let pokestop = pokestop else { return nil }
        if let views = Bundle.main.loadNibNamed("PokestopDetailAnnotationView",
                                                owner: self,
                                                options: nil) as? [PokestopDetailAnnotationView], views.count > 0 {
            let pokestopDetailAnnotationView = views.first!
            pokestopDetailAnnotationView.configure(with: pokestop)
            pokestopDetailAnnotationView.delegate = delegate
            return pokestopDetailAnnotationView
        }
        return nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.customCalloutView?.removeFromSuperview() // remove old custom callout (if any)
            
            if let newCustomCalloutView = loadPokestopDetailAnnotationView() {
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
                } else { self.customCalloutView!.removeFromSuperview() } // just remove it.
            }
        }
    }
    
    class func prepareFor(mapView: MKMapView, annotation: PokestopPointAnnotation) -> PokestopAnnotationView? {
        let reuseId = "pokestopAnnotationReuseIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if annotationView == nil {
            let pokestopAnnotationView = PokestopAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pokestopAnnotationView.pokestop = annotation.pokestop
            annotationView = pokestopAnnotationView
        } else {
            if let pokestopAnnotationView = annotationView as? PokestopAnnotationView {
                pokestopAnnotationView.annotation = annotation
                pokestopAnnotationView.pokestop = annotation.pokestop
            }
        }
        annotationView?.image = UIImage(named: annotation.imageName)
        return annotationView as? PokestopAnnotationView
    }
}
