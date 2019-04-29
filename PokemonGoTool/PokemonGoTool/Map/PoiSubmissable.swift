
import UIKit
import MapKit

protocol PoiSubmissable {
    var mapView: MKMapView! { get set }
    var poiSubmissionMode: Bool { get set }
    var poiSubmissionAnnotation: MKPointAnnotation! { get set }
}

extension PoiSubmissable where Self: UIViewController {
    
    func startPoiSubmission(submitClosure: @escaping () -> Void, endClosure: @escaping () -> Void) {
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
        stackView.tag = 1337
        stackView.alpha = 0
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([view.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: -16),
                                     view.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: 16),
                                     view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 25)])
        
        UIView.animate(withDuration: 0.25, animations: { stackView.alpha = 1 })
    }
    
    private func endPoiSubmission() {
        mapView.removeAnnotation(poiSubmissionAnnotation)
        guard let stackView = view.viewWithTag(1337) else { return }
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
