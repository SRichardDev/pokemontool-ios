
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
            labelOffsetY = 20
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
        var annotationView: MKAnnotationView?
        if let pokestopAnnoation = annotation as? PokestopPointAnnotation {
            annotationView = AnnotationView.preparePokestopAnnotation(in: mapView, for: pokestopAnnoation, showLabel: showLabel)
        }
        if let arenaAnnotation = annotation as? ArenaPointAnnotation {
            annotationView = AnnotationView.prepareArenaAnnotation(in: mapView, for: arenaAnnotation, showLabel: showLabel)
        }
        return annotationView as? AnnotationView
    }
    
    private class func prepareArenaAnnotation(in mapView: MKMapView,
                                        for annotation: ArenaPointAnnotation,
                                        showLabel: Bool = false) -> MKAnnotationView? {
        let reuseId = "arenaReuseIdentifier"
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? AnnotationView {
            annotationView.annotation = annotation
            return AnnotationView.setupArenaAnnotationView(annotationView: annotationView, for: annotation, showLabel: showLabel)
        } else {
            let annotationView = AnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            return AnnotationView.setupArenaAnnotationView(annotationView: annotationView, for: annotation, showLabel: showLabel)
        }
    }
    
    private class func setupArenaAnnotationView(annotationView: AnnotationView,
                                        for annotation: ArenaPointAnnotation,
                                        showLabel: Bool) -> AnnotationView {
        annotationView.label.alpha = showLabel ? 1 : 0
        annotationView.customAnnotation = annotation.arena
        
        let baseImage = UIImage(named: annotation.imageName)!

        
        if let raid = annotation.arena?.raid {
            if !raid.isExpired {
                let topImage = UIImage(named: annotation.raidEggImageName)!
                let size = CGSize(width: topImage.size.width/2, height: topImage.size.height/2)
                let resizedTopImage = topImage.resize(targetSize: size)
                annotationView.image = UIImage.imageByCombiningImage(firstImage: baseImage, withImage: resizedTopImage)
                
                if raid.level == 5 {
                    annotationView.addPulsator(numPulses: 1, color: .purple)
                } else if raid.level == 4 {
                    annotationView.addPulsator(numPulses: 1, color: .yellow)
                } else if raid.level == 3 {
                    annotationView.addPulsator(numPulses: 1, color: .orange)
                } else if raid.level == 2 {
                    annotationView.addPulsator(numPulses: 1, color: .red)
                } else if raid.level == 1 {
                    annotationView.addPulsator(numPulses: 1, color: .magenta)
                }
            }
        } else {
            annotationView.image = baseImage
        }
        return annotationView
    }
    
    private class func preparePokestopAnnotation(in mapView: MKMapView,
                                           for annotation: PokestopPointAnnotation,
                                           showLabel: Bool = false) -> MKAnnotationView? {
        let reuseId = "pokestopReuseIdentifier"
        
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? AnnotationView {
            annotationView.annotation = annotation
            return AnnotationView.setupPokestopAnnotationView(annotationView: annotationView, for: annotation, showLabel: showLabel)
        } else {
            let annotationView = AnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            return AnnotationView.setupPokestopAnnotationView(annotationView: annotationView, for: annotation, showLabel: showLabel)
        }
    }
    
    private class func setupPokestopAnnotationView(annotationView: AnnotationView,
                                           for annotation: PokestopPointAnnotation,
                                           showLabel: Bool) -> AnnotationView {
        annotationView.customAnnotation = annotation.pokestop
        annotationView.label.alpha = showLabel ? 1 : 0
        
        if let image = ImageManager.image(named: annotation.imageName) {
            let baseImage = UIImage(named: "Pokestop")!
            let size = CGSize(width: image.size.width/2, height: image.size.height/2)
            let topImage = image.resize(targetSize: size)
            annotationView.image = UIImage.imageByCombiningImage(firstImage: baseImage, withImage: topImage)
        } else {
            annotationView.image = UIImage(named: "Pokestop")!
        }
        return annotationView
    }
}
