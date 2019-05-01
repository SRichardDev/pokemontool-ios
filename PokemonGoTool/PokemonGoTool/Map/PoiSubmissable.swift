
import UIKit
import MapKit

protocol PoiSubmissable {
    var mapView: MKMapView! { get set }
    var poiSubmissionMode: Bool { get set }
    var poiSubmissionAnnotation: MKPointAnnotation! { get set }
}

struct ViewTags {
    static let poiSubmissionStackView = 1337
}

struct ConstraintIdentifiers {
    static let settingsMenuRightConstraint = "settingsMenu"
}

extension PoiSubmissable where Self: UIViewController {
    
    func startPoiSubmission(submitClosure: @escaping () -> Void, endClosure: @escaping () -> Void) {
        
        let viewRegion = MKCoordinateRegion(center: mapView.centerCoordinate,
                                            latitudinalMeters: 100,
                                            longitudinalMeters: 100)
        mapView.setRegion(viewRegion, animated: true)

        
        poiSubmissionAnnotation.coordinate = mapView.centerCoordinate
        mapView.addAnnotation(poiSubmissionAnnotation)
        
        let submitButton = Button()
        submitButton.setTitle("Einreichen", for: .normal)
        submitButton.addAction {
            self.endPoiSubmission()
            submitClosure()
        }
        
        let cancelButton = Button()
        cancelButton.setTitle("Abbrechen", for: .normal)
        cancelButton.addAction {
            self.endPoiSubmission()
            endClosure()
        }
        
        let stackView = UIStackView(arrangedSubviews: [cancelButton, submitButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        stackView.tag = ViewTags.poiSubmissionStackView
        stackView.alpha = 0
        view.addSubview(stackView)
        
        view.addSubviewAndEdgeConstraints(stackView, edges: [.left,.right,.bottom],
                                          margins: UIEdgeInsets(top: 0, left: 16, bottom: 25, right: 16),
                                          constrainToSafeAreaGuide: true)
                
        UIView.animate(withDuration: 0.25, animations: { stackView.alpha = 1 })
    }
    
    private func endPoiSubmission() {
        mapView.removeAnnotation(poiSubmissionAnnotation)
        guard let stackView = view.viewWithTag(ViewTags.poiSubmissionStackView) else { return }
        UIView.animate(withDuration: 0.25, animations: {stackView.alpha = 0}) { _ in
            stackView.removeFromSuperview()
        }
    }
    
    func updatePoiSubmissionCoordinate(_ coordinate: CLLocationCoordinate2D) {
        guard poiSubmissionMode else { return }
        UIView.animate(withDuration: 0.05) {
            self.poiSubmissionAnnotation.coordinate = coordinate
        }
    }
}
