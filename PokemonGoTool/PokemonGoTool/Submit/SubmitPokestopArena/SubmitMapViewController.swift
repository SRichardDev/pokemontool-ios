
import UIKit
import MapKit

protocol SubmitMapEmbeddable {
    var containerView: UIView! { get set }
    func embedMap(coordinate: CLLocationCoordinate2D,mapType: MKMapType, isFlyover: Bool) -> SubmitMapViewController
}

extension SubmitMapEmbeddable where Self: UIViewController {
    @discardableResult
    func embedMap(coordinate: CLLocationCoordinate2D,
                  mapType: MKMapType = .standard,
                  isFlyover: Bool = false) -> SubmitMapViewController {
        
        let mapViewController = SubmitMapViewController()
        mapViewController.locationOnMap = coordinate
        mapViewController.mapView.mapType = mapType
        mapViewController.isFlyover = isFlyover
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
    var camera: MKMapCamera?
    var isFlyover = false

    let mapView = MKMapView()
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
        mapView.addAnnotation(pokestopAnnotation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let distance: CLLocationDistance = 200
        let pitch: CGFloat = 65
        let heading = 180.0
        
        camera = MKMapCamera(lookingAtCenter: locationOnMap,
                             fromDistance: distance,
                             pitch: pitch,
                             heading: heading)
        mapView.camera = camera!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startFlyover()
    }
    
    func startFlyover() {
        UIView.animate(withDuration: 5.0, animations: {
            self.camera!.heading += 180
            self.camera!.pitch = 45
            self.mapView.camera = self.camera!
        })
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = AnnotationView.prepareFor(mapView: mapView, annotation: annotation)
        annotationView?.isDraggable = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        switch newState {
        case .starting:
            view.dragState = .dragging
            UIView.animate(withDuration: 0.25) {
                view.transform = CGAffineTransform(translationX: 0, y: -50)
            }
        case .ending, .canceling:
            locationOnMap = view.annotation?.coordinate
            view.dragState = .none
            UIView.animate(withDuration: 0.25) {
                view.transform = .identity
            }
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
