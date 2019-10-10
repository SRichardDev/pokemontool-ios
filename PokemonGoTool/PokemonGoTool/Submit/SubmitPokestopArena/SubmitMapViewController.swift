
import UIKit
import MapKit

protocol MapEmbeddable {
    var containerView: UIView! { get set }
    func embedMap(coordinate: CLLocationCoordinate2D, mapType: MKMapType, isFlyover: Bool) -> SubmitMapViewController
}

extension MapEmbeddable where Self: UIViewController {
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
    private var camera: MKMapCamera!
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
    
    private let stackView = InnerVerticalStackView()
    private let slider = Degree360Slider()
    
    
    class func setup(with coordinate: CLLocationCoordinate2D, isPokestop: Bool = true) -> SubmitMapViewController {
        let submitMapViewController = SubmitMapViewController()
        submitMapViewController.locationOnMap = coordinate
        let annotation = isPokestop ? submitMapViewController.pokestopAnnotation : submitMapViewController.arenaAnnotation
        submitMapViewController.mapView.addAnnotation(annotation)
        submitMapViewController.mapView.mapType = .mutedStandard

//        DispatchQueue.global().async {
//            switch Network.reachability.status {
//            case .unreachable:
//                submitMapViewController.mapView.mapType = .mutedStandard
//            case .wwan:
//                submitMapViewController.mapView.mapType = .mutedStandard
//            case .wifi:
//                submitMapViewController.mapView.mapType = .satelliteFlyover
//            }
//        }
        submitMapViewController.isFlyover = true
        return submitMapViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startFlyover()
    }
    
    private func setup() {
        stackView.axis = .vertical
        view.addSubviewAndEdgeConstraints(stackView)
        stackView.addArrangedSubview(mapView)
        stackView.addArrangedSubview(slider)
        
        slider.setup()
        slider.addTarget(self, action: #selector(sliderValueDidChange(sender:)), for: .valueChanged)
        
        
        mapView.heightAnchor.constraint(equalTo: mapView.widthAnchor, multiplier: 1/1).isActive = true
        mapView.delegate = self
        mapView.layer.cornerRadius = 10
        
        let distance: CLLocationDistance = 400
        let pitch: CGFloat = 65
        let heading = 180.0
        
        camera = MKMapCamera(lookingAtCenter: locationOnMap,
                             fromDistance: distance,
                             pitch: pitch,
                             heading: heading)
        mapView.camera = camera
    }
    
    @objc
    func sliderValueDidChange(sender: UISlider) {
        camera.heading = CLLocationDirection(exactly: sender.value)!
        mapView.camera = camera
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
