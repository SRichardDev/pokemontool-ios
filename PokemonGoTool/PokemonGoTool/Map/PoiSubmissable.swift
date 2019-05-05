
import UIKit
import MapKit

protocol PoiSubmissable {
    var mapView: MKMapView! { get set }
    var isPoiSubmissionMode: Bool { get set }
    var poiSubmissionAnnotation: MKPointAnnotation! { get set }
}

extension PoiSubmissable where Self: UIViewController & BottomMenuShowable & MapRegionSetable {
    
    func startPoiSubmission(submitClosure: @escaping () -> Void, endClosure: @escaping () -> Void) {
        
        tabBarController?.tabBar.isHidden = true

        setMapRegion(distance: 100)
        poiSubmissionAnnotation.coordinate = mapView.centerCoordinate
        mapView.addAnnotation(poiSubmissionAnnotation)
        
        let submitButton = CircleButton(type: .custom)
        submitButton.type = .accept
        submitButton.addAction {
            submitButton.scaleIn()
            self.endPoiSubmission()
            submitClosure()
        }
        
        let cancelButton = CircleButton(type: .custom)
        cancelButton.type = .cancel
        cancelButton.addAction {
            cancelButton.scaleIn()
            self.endPoiSubmission()
            endClosure()
        }
        
        let menuView = showBottomMenu([cancelButton, submitButton])
        menuView.tag = ViewTags.poiSubmissionStackView
    }
    
    private func endPoiSubmission() {
        tabBarController?.tabBar.isHidden = false
        mapView.removeAnnotation(poiSubmissionAnnotation)
        guard let stackView = view.viewWithTag(ViewTags.poiSubmissionStackView) else { return }
        UIView.animate(withDuration: 0.25, animations: {stackView.alpha = 0}) { _ in stackView.removeFromSuperview() }
    }
    
    func updatePoiSubmissionCoordinate(_ coordinate: CLLocationCoordinate2D) {
        guard isPoiSubmissionMode else { return }
        UIView.animate(withDuration: 0.05) { self.poiSubmissionAnnotation.coordinate = coordinate }
    }
}
