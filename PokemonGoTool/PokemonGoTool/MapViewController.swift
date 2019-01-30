
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, AppModuleAccessible {
    
    @IBOutlet private var mapView: MKMapView!
    var locationManager: LocationManager!
    var firebaseConnector: FirebaseConnector!
    private var polygon: MKPolygon?
    private var allAnnotations = [PokestopPointAnnotation]()
    private var geohashWindow: GeohashWindow?
    private var selectedGeohashes = [String]()
    private var isGeoashSelectionMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        zoomToUserLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.delegate = self
        firebaseConnector.delegate = self
    }
    
    func zoomToUserLocation(animated: Bool = false) {
        if let userLocation = locationManager.currentUserLocation {
            let viewRegion = MKCoordinateRegion(center: userLocation.coordinate,
                                                latitudinalMeters: 1500,
                                                longitudinalMeters: 1500)
            mapView.setRegion(viewRegion, animated: animated)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        removeAnnotationIfNeeded()
        mapView.removeOverlays(mapView.overlays)
        let mapRect = mapView.visibleMapRect
        let topLeft = MapRectUtility.getNorthWestCoordinate(in: mapRect)
        let topRight = MapRectUtility.getNorthEastCoordinate(in: mapRect)
        let bottomLeft = MapRectUtility.getSouthWestCoordinate(in: mapRect)
        let bottomRight = MapRectUtility.getSouthEastCoordinate(in: mapRect)
        geohashWindow = GeohashWindow(topLeftCoordinate: topLeft,
                                      topRightCoordiante: topRight,
                                      bottomLeftCoordinated: bottomLeft,
                                      bottomRightCoordiante: bottomRight)
        
        geohashWindow?.geohashMatrix.forEach { lineArray in
            lineArray.forEach { geohashBox in
                addPolyLine(for: geohashBox)
                firebaseConnector.loadPokestops(for: geohashBox.hash)
                firebaseConnector.loadArenas(for: geohashBox.hash)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: polyline)
            polylineRenderer.strokeColor = isGeoashSelectionMode ? UIColor.red.withAlphaComponent(0.5) : UIColor.blue.withAlphaComponent(0.1)
            polylineRenderer.lineWidth = 1
            return polylineRenderer
        } else {
            let renderer = MKPolygonRenderer(polygon: polygon!)
            renderer.fillColor = isGeoashSelectionMode ? UIColor.orange.withAlphaComponent(0.2) : UIColor.green.withAlphaComponent(0.2)
            return renderer
        }
    }
    
    func addPolyLine(for geohashBox: GeohashBox?) {
        guard let geohashBox = geohashBox else { return }
        let polyLine = MKPolyline.polyline(for: geohashBox)
//        let polygon = MKPolygon.polygon(for: geohashBox)
//        self.polygon = polygon
        mapView.addOverlay(polyLine)
//        mapView.addOverlay(polygon)
    }
    
    @IBAction func longPressOnMap(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let navigationController = SubmitViewController.instantiateFromStoryboardInNavigationController()
            let submitPokestopViewController = navigationController.topViewController as! SubmitViewController
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            let viewModel = SubmitViewModel(firebaseConnector: firebaseConnector, coordinate: locationOnMap)
            submitPokestopViewController.viewModel = viewModel

            let feedback = UIImpactFeedbackGenerator(style: .heavy)
            feedback.impactOccurred()
            present(navigationController, animated: true)
        }
    }
    
    @IBAction func tappedMap(_ sender: UITapGestureRecognizer) {
        let locationInView = sender.location(in: mapView)
        let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
        let geohash = Geohash.encode(latitude: locationOnMap.latitude, longitude: locationOnMap.longitude)
        if isGeoashSelectionMode {
            firebaseConnector.subscribeForPush(for: geohash)
            addPolyLine(for: Geohash.geohashbox(geohash))
        }
    }
    
    @IBAction func toggleGeohashSelectionMode(_ sender: UIButton) {
        isGeoashSelectionMode = !isGeoashSelectionMode
        isGeoashSelectionMode ? sender.setTitle("✅", for: .normal) : sender.setTitle("📡", for: .normal)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? PokestopPointAnnotation  {
            let annotationView = AnnotationView.prepareFor(mapView: mapView, annotation: annotation)
            annotationView?.delegate = self
            return annotationView
        } else if let annotation = annotation as? ArenaPointAnnotation  {
            let annotationView = AnnotationView.prepareFor(mapView: mapView, annotation: annotation)
            annotationView?.delegate = self
            return annotationView
        }
        return nil
    }
    
    func addAnnotations(for annotations: [Annotation]) {
        for annotation in annotations {
            if let pokestopAnnotation = annotation as? Pokestop {
                let annotation = PokestopPointAnnotation(pokestop: pokestopAnnotation)
                addAnnotationIfNeeded(annotation)
            } else if let arenaAnnotation = annotation as? Arena {
                let annotation = ArenaPointAnnotation(arena: arenaAnnotation)
                addAnnotationIfNeeded(annotation)
            }
        }
    }
}

extension MapViewController: FirebaseDelegate {
    func didUpdateArenas() {
        addAnnotations(for: firebaseConnector.arenas)
    }
    
    func didUpdatePokestops() {
        addAnnotations(for: firebaseConnector.pokestops)
    }
}

extension MapViewController: LocationManagerDelegate {
    
    func didFindInitialUserLocation() {
        zoomToUserLocation()
    }
}

extension MapViewController {
    
    func addAnnotationIfNeeded(_ annotation: MKAnnotation) {
        
        if let pokestopAnnotation = annotation as? PokestopPointAnnotation {
            var pokestopFound = false
            self.mapView.annotations.forEach { annotationOnMap in
                guard let annotationOnMap = annotationOnMap as? PokestopPointAnnotation else { return }
                if annotationOnMap.pokestop.id == pokestopAnnotation.pokestop.id {
                    pokestopFound = true
                }
            }
            if !pokestopFound {
                self.mapView.addAnnotation(annotation)
            }
        } else if let arenaAnnotation = annotation as? ArenaPointAnnotation {
            var arenaFound = false
            self.mapView.annotations.forEach { annotationOnMap in
                guard let annotationOnMap = annotationOnMap as? ArenaPointAnnotation else { return }
                if annotationOnMap.arena.id == arenaAnnotation.arena.id {
                    arenaFound = true
                }
            }
            if !arenaFound {
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func removeAnnotationIfNeeded() {
        mapView.annotations.forEach {
            guard let annotation = $0 as? GeohashStringRepresentable else { return }
            var foundAnnotationGeohash = false
            
            geohashWindow?.geohashMatrix.forEach { lineArray in
                for geohashBox in lineArray {
                    if annotation.geohash == geohashBox.hash {
                        foundAnnotationGeohash = true
                        break
                    }
                }
            }
            
            if !foundAnnotationGeohash {
                mapView.removeAnnotation(annotation as! MKAnnotation)
            }
        }
    }
}

extension MapViewController: DetailAnnotationViewDelegate {
    func showDetail(for annotation: Annotation) {
        
        if let pokestopAnnotation = annotation as? Pokestop {
            let navigationController = SubmitQuestViewController.instantiateFromStoryboardInNavigationController()
            let submitQuestViewController = navigationController.topViewController as! SubmitQuestViewController
            submitQuestViewController.pokestop = pokestopAnnotation
            submitQuestViewController.firebaseConnector = firebaseConnector
            present(navigationController, animated: true)
        }
        
        if let arenaAnnotation = annotation as? Arena {
            let submitRaidDetailsViewController = SubmitRaidDetailsViewController.instantiateFromStoryboard()
            let scrollableViewController = ScrollableViewController(childViewController: submitRaidDetailsViewController)
            let navigationController = UINavigationController(rootViewController: scrollableViewController)
            navigationController.navigationBar.prefersLargeTitles = true
            present(navigationController, animated: true)
        }
    }
}
