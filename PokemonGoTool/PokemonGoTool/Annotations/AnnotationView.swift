
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
        guard isUserInteractionEnabled else { return nil }
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
                    self.customCalloutView?.alpha = 0.0
                    UIView.animate(withDuration: animationTime, animations: {
                        self.customCalloutView?.alpha = 1.0
                    })
                }
            }
        } else {
            if customCalloutView != nil {
                if animated { // fade out animation, then remove it.
                    UIView.animate(withDuration: animationTime, animations: {
                        self.customCalloutView?.alpha = 0.0
                    }, completion: { (success) in
                        self.customCalloutView?.removeFromSuperview()
                    })
                } else {
                    self.customCalloutView?.removeFromSuperview()
                }
            }
        }
    }
    
    class func prepareFor(mapView: MKMapView,
                          annotation: MKAnnotation,
                          showLabel: Bool = false) -> AnnotationView? {
        
        var annotationView: MKAnnotationView?
        if let pokestopAnnoation = annotation as? PokestopPointAnnotation {
            annotationView = AnnotationView.preparePokestopAnnotation(in: mapView,
                                                                      for: pokestopAnnoation,
                                                                      showLabel: showLabel)
        }
        if let arenaAnnotation = annotation as? ArenaPointAnnotation {
            annotationView = AnnotationView.prepareArenaAnnotation(in: mapView,
                                                                   for: arenaAnnotation,
                                                                   showLabel: showLabel)
        }
        return annotationView as? AnnotationView
    }
    
    private class func prepareArenaAnnotation(in mapView: MKMapView,
                                              for annotation: ArenaPointAnnotation,
                                              showLabel: Bool = false) -> MKAnnotationView? {
        
        let reuseId = "arenaReuseIdentifier"
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? AnnotationView {
            annotationView.annotation = annotation
            return AnnotationView.setupArenaAnnotationView(annotationView: annotationView,
                                                           for: annotation,
                                                           showLabel: showLabel)
        } else {
            let annotationView = AnnotationView(annotation: annotation,
                                                reuseIdentifier: reuseId)
            
            return AnnotationView.setupArenaAnnotationView(annotationView: annotationView,
                                                           for: annotation,
                                                           showLabel: showLabel)
        }
    }
    
    private class func setupArenaAnnotationView(annotationView: AnnotationView,
                                                for annotation: ArenaPointAnnotation,
                                                showLabel: Bool) -> AnnotationView {
        
        annotationView.label.alpha = showLabel ? 1 : 0
        annotationView.customAnnotation = annotation.arena
        
        if let raid = annotation.arena?.raid,
            let arena = annotation.arena,
            !raid.isExpired {
            
            annotationView.image = ImageManager.combinedArenaImage(for: arena)
            
            switch raid.level {
            case 5:
                annotationView.addPulsator(numPulses: 1, color: .purple)
            case 4:
                annotationView.addPulsator(numPulses: 1, color: .yellow)
            case 3:
                annotationView.addPulsator(numPulses: 1, color: .orange)
            case 2:
                annotationView.addPulsator(numPulses: 1, color: .red)
            case 1:
                annotationView.addPulsator(numPulses: 1, color: .magenta)
            default:
                break
            }
            
            if let participantsCount = raid.meetup?.participants?.count {
                annotationView.addParticipantsCountBadge(participantsCount)
            }
        } else {
            let baseImage = annotation.arena?.image ?? UIImage(named: "arena")!
            let size = CGSize(width: baseImage.size.width/2, height: baseImage.size.height/2)
            let resizedBaseImage = baseImage.resize(targetSize: size)
            
            annotationView.image = resizedBaseImage
        }
        
        return annotationView
    }
    
    private class func preparePokestopAnnotation(in mapView: MKMapView,
                                           for annotation: PokestopPointAnnotation,
                                           showLabel: Bool = false) -> MKAnnotationView? {
        let reuseId = "pokestopReuseIdentifier"
        
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? AnnotationView {
            annotationView.annotation = annotation
            return AnnotationView.setupPokestopAnnotationView(annotationView: annotationView,
                                                              for: annotation,
                                                              showLabel: showLabel)
        } else {
            let annotationView = AnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            return AnnotationView.setupPokestopAnnotationView(annotationView: annotationView,
                                                              for: annotation,
                                                              showLabel: showLabel)
        }
    }
    
    private class func setupPokestopAnnotationView(annotationView: AnnotationView,
                                                   for annotation: PokestopPointAnnotation,
                                                   showLabel: Bool) -> AnnotationView {
        annotationView.customAnnotation = annotation.pokestop
        annotationView.label.alpha = showLabel ? 1 : 0
        
        if let quest = annotation.pokestop?.quest, quest.isActive, let image = ImageManager.image(named: annotation.imageName) {
            let baseImage = UIImage(named: "Pokestop")!
            let size = CGSize(width: image.size.width/3, height: image.size.height/3)
            let topImage = image.resize(targetSize: size)
            let background = UIImage(named: "iconBackground")!
            let combined = UIImage.imageByCombiningImage(firstImage: background, withImage: topImage)
            annotationView.image = UIImage.imageByCombiningImage(firstImage: baseImage, withImage: combined)
        } else if let incident = annotation.pokestop?.incident, incident.isActive {
            let baseImage = UIImage(named: "PokestopIncident")!
            let typeImage = incident.image
            let typeImageSize = CGSize(width: typeImage.size.width/2, height: typeImage.size.height/2)
            let combined = UIImage.imageByCombiningImage(firstImage: baseImage, withImage: typeImage.resize(targetSize: typeImageSize))
            annotationView.image = combined
        } else {
            annotationView.image = UIImage(named: "Pokestop")!
        }
        
        return annotationView
    }
}
