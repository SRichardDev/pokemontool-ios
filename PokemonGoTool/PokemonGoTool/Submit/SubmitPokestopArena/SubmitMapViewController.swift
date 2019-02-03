
import UIKit
import MapKit

protocol SubmitMapEmbeddable {
    var containerView: UIView! { get set }
    func embedMap(coordinate: CLLocationCoordinate2D) -> SubmitMapViewController
}

extension SubmitMapEmbeddable where Self: UIViewController {
    @discardableResult
    func embedMap(coordinate: CLLocationCoordinate2D) -> SubmitMapViewController {
        let mapViewController = SubmitMapViewController()
        mapViewController.locationOnMap = coordinate
        addChild(mapViewController)
        mapViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        mapViewController.view.frame = containerView.bounds
        containerView.addSubview(mapViewController.view)
        mapViewController.didMove(toParent: self)
        return mapViewController
    }
}

class SubmitMapViewController: UIViewController, MKMapViewDelegate {
    
    var locationOnMap: CLLocationCoordinate2D!
    
    private let mapView = MKMapView()
    private var pokestopAnnotation: PokestopPointAnnotation {
        get {
            return PokestopPointAnnotation(coordinate: locationOnMap)
        }
    }
    
    private var arenaAnnotation: ArenaPointAnnotation {
        get {
            return ArenaPointAnnotation(coordinate: locationOnMap)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviewAndEdgeConstraints(mapView)
        mapView.delegate = self
        mapView.layer.cornerRadius = 10
        let viewRegion = MKCoordinateRegion(center: locationOnMap,
                                            latitudinalMeters: 120,
                                            longitudinalMeters: 120)
        mapView.setRegion(viewRegion, animated: false)
        mapView.addAnnotation(pokestopAnnotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = AnnotationView.prepareFor(mapView: mapView, annotation: annotation)
        annotationView?.isDraggable = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        locationOnMap = view.annotation?.coordinate
        switch newState {
        case .starting:
            view.dragState = .dragging
        case .ending, .canceling:
            view.dragState = .none
        default: break
        }
    }
    
    func addPokestopAnnotation() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(pokestopAnnotation)
    }
    
    func addArenaAnnotation() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(arenaAnnotation)
    }
}
