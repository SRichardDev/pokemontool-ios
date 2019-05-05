
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

struct ConstraintConstants {
    static let mapMenuOrigin: CGFloat = 15
    static let mapMenuOffScreen: CGFloat = -500
}

extension PoiSubmissable where Self: UIViewController & BottomMenuShowable {
    
    func startPoiSubmission(submitClosure: @escaping () -> Void, endClosure: @escaping () -> Void) {
        
        tabBarController?.tabBar.isHidden = true

        let viewRegion = MKCoordinateRegion(center: mapView.centerCoordinate,
                                            latitudinalMeters: 100,
                                            longitudinalMeters: 100)
        mapView.setRegion(viewRegion, animated: true)
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
        guard poiSubmissionMode else { return }
        UIView.animate(withDuration: 0.05) { self.poiSubmissionAnnotation.coordinate = coordinate }
    }
}

protocol BottomMenuShowable {}

extension BottomMenuShowable where Self: UIViewController {
    
    @discardableResult
    func showBottomMenu(_ buttons: [UIButton]) -> UIView {
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 40
        stackView.alpha = 0
        view.addSubview(stackView)
        
        view.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 25).isActive = true
        
        UIView.animate(withDuration: 0.25, animations: { stackView.alpha = 1 })
        return stackView
    }
}

protocol GeohashRegisterable: class {
    var mapView: MKMapView! { get set }
    var polygon: MKPolygon? { get set }
}

extension GeohashRegisterable where Self: UIViewController & BottomMenuShowable {
    
    func startGeohashRegistration(with currentGeohashes: [String]) {
        
        currentGeohashes.forEach { addPolyLine(for: Geohash.geohashbox($0)) }
        
        let submitButton = CircleButton(type: .custom)
        submitButton.type = .accept
        submitButton.addAction {
            submitButton.scaleIn()
        }
        
        let cancelButton = CircleButton(type: .custom)
        cancelButton.type = .cancel
        cancelButton.addAction {
            cancelButton.scaleIn()
            self.endGeohashRegistration()
        }
        
        let menuView = showBottomMenu([cancelButton, submitButton])
        menuView.tag = ViewTags.poiSubmissionStackView
    }
    
    func endGeohashRegistration() {
        mapView.removeOverlays(mapView.overlays)
    }
    
    func addPolyLine(for geohashBox: GeohashBox?) {
        guard let geohashBox = geohashBox else { return }
        let polyLine = MKPolyline.polyline(for: geohashBox)
        let polygon = MKPolygon.polygon(for: geohashBox)
        self.polygon = polygon
        mapView.addOverlay(polyLine)
        mapView.addOverlay(polygon)
    }
}
