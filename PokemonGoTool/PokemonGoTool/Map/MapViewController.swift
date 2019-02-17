
import UIKit
import MapKit
import NotificationBannerSwift
import Cluster

class MapViewController: UIViewController, MKMapViewDelegate, StoryboardInitialViewController, MapTypeSwitchable {
    
    weak var coordinator: MainCoordinator?
    var locationManager: LocationManager!
    var firebaseConnector: FirebaseConnector!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var settingsButtonsView: UIView!
    @IBOutlet var backgroundLabel: UILabel!
    @IBOutlet var mapCrosshairView: MapCrosshair!
    var polygon: MKPolygon?
    var allAnnotations = [PokestopPointAnnotation]()
    var geohashWindow: GeohashWindow?
    var selectedGeohashes = [String]()
    var isGeohashSelectionMode = false
    var currentlyShowingLabels = true
    var mapRegionFromPush: MKCoordinateRegion?
    
    lazy var manager: ClusterManager = {
        let manager = ClusterManager()
        manager.delegate = self
        manager.maxZoomLevel = 17
        manager.minCountForClustering = 3
        manager.clusterPosition = .average
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator?.appModule.pushManager.delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = true
        zoomToUserLocation()
        setupMapButtonsMenu()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.delegate = self
        firebaseConnector.delegate = self
        zoomToLocationFromPushIfNeeded()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        removeAnnotationIfNeeded()
        
        //TODO: Fix crash when tilting map. Do adding/removing annotations on main thread
//        mapView.removeOverlays(mapView.overlays)
        
        let mapRect = mapView.visibleMapRect
        geohashWindow = GeohashWindow(topLeftCoordinate: MapRectUtility.getNorthWestCoordinate(in: mapRect),
                                      topRightCoordiante: MapRectUtility.getNorthEastCoordinate(in: mapRect),
                                      bottomLeftCoordinate: MapRectUtility.getSouthWestCoordinate(in: mapRect),
                                      bottomRightCoordiante: MapRectUtility.getSouthEastCoordinate(in: mapRect))
        
        geohashWindow?.geohashMatrix.forEach { lineArray in
            lineArray.forEach { geohashBox in
//                addPolyLine(for: geohashBox)
                firebaseConnector.loadPokestops(for: geohashBox.hash)
                firebaseConnector.loadArenas(for: geohashBox.hash)
            }
        }

        changeAnnotationLabelVisibility()
        manager.reload(mapView: mapView)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pin.image = ImageManager.image(named: "25-original-cap")?.resize(scaleFactor: 0.5)
            pin.addPulsator()
            return pin
        }
        
        if let annotation = annotation as? ClusterAnnotation {
            return mapView.annotationView(annotation: annotation, reuseIdentifier: "identifier")
        }
        
        let annotationView = AnnotationView.prepareFor(mapView: mapView,
                                                       annotation: annotation,
                                                       showLabel: currentlyShowingLabels)
        annotationView?.delegate = self
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: polyline)
            polylineRenderer.strokeColor = isGeohashSelectionMode ? UIColor.red.withAlphaComponent(0.5) : UIColor.blue.withAlphaComponent(0.1)
            polylineRenderer.lineWidth = 1
            return polylineRenderer
        } else {
            let renderer = MKPolygonRenderer(polygon: polygon!)
            renderer.fillColor = isGeohashSelectionMode ? UIColor.orange.withAlphaComponent(0.2) : UIColor.green.withAlphaComponent(0.2)
            return renderer
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        views.forEach { $0.alpha = 0 }
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
            views.forEach { $0.alpha = 1 }
        }, completion: nil)
    }

    func changeAnnotationLabelVisibility() {
        let showLabels = mapView.camera.altitude < 2000.0
        
        if showLabels != currentlyShowingLabels {
            currentlyShowingLabels = showLabels
            mapView.annotations.forEach { annotation in
                if let annotationView = self.mapView.view(for: annotation) as? AnnotationView {
                    annotationView.changeLabelVisibilityAnimated(showLabels)
                }
            }
        }
    }
    
    func addPolyLine(for geohashBox: GeohashBox?) {
        guard let geohashBox = geohashBox else { return }
        let polyLine = MKPolyline.polyline(for: geohashBox)
        let polygon = MKPolygon.polygon(for: geohashBox)
        self.polygon = polygon
        mapView.addOverlay(polyLine)
//        mapView.addOverlay(polygon)
    }
    
    func addAnnotations(for annotations: [Annotation]) {
        
        manager.removeAll()
        manager.reload(mapView: mapView)
        var mapAnnotations = [MKAnnotation]()

        for annotation in annotations {
            if let pokestopAnnotation = annotation as? Pokestop {
                let annotation = PokestopPointAnnotation(pokestop: pokestopAnnotation, quests: firebaseConnector?.quests)
                mapAnnotations.append(annotation)
                
            } else if let arenaAnnotation = annotation as? Arena {
                let annotation = ArenaPointAnnotation(arena: arenaAnnotation)
                mapAnnotations.append(annotation)
            }
        }
        manager.add(mapAnnotations)
        manager.reload(mapView: mapView)
    }
    
    func didUpdateAnnotation(newAnnotation: Annotation) {
        let annotation = mapView.annotations.first { annotatinon -> Bool in
            if let pokestopAnnotatinon = annotatinon as? PokestopPointAnnotation {
                if pokestopAnnotatinon.pokestop.id == newAnnotation.id {
                    return true
                }
            } else if let arenaAnnotation = annotatinon as? ArenaPointAnnotation {
                if arenaAnnotation.arena.id == newAnnotation.id {
                    return true
                }
            }
            return false
        }
        
        guard let presentAnnotation = annotation else { return }
        mapView.removeAnnotation(presentAnnotation)
        
        if let pokestopAnnotation = newAnnotation as? Pokestop {
            let annotation = PokestopPointAnnotation(pokestop: pokestopAnnotation, quests: firebaseConnector?.quests)
            mapView.addAnnotation(annotation)
        } else if let arenaAnnotation = newAnnotation as? Arena {
            let annotation = ArenaPointAnnotation(arena: arenaAnnotation)
            mapView.addAnnotation(annotation)
        }
    }
}

extension MapViewController: FirebaseDelegate {
    func didUpdateArenas(arena: Arena) {
        let annotation = ArenaPointAnnotation(arena: arena)
        manager.add(annotation)
        manager.reload(mapView: mapView)
    }
    
    func didUpdatePokestops(pokestop: Pokestop) {
        let annotation = PokestopPointAnnotation(pokestop: pokestop, quests: firebaseConnector?.quests)
        manager.add(annotation)
        manager.reload(mapView: mapView)
    }
}

extension MapViewController: LocationManagerDelegate {
    func didFindInitialUserLocation() {
        zoomToUserLocation()
    }
}

extension MapViewController: DetailAnnotationViewDelegate {
    
    func showInfoDetail(for annotation: Annotation) {
        if let pokestopAnnotation = annotation as? Pokestop {
//            guard let pokestop = firebaseConnector.pokestops.first(where: { $0.id == pokestopAnnotation.id }) else { return }
            coordinator?.showPokestopDetails(for: pokestopAnnotation)
        } else if let _ = annotation as? Arena {

        }
    }
    
    func showSubmitDetail(for annotation: Annotation) {
        if let pokestopAnnotation = annotation as? Pokestop {
            coordinator?.showSubmitQuest(for: pokestopAnnotation)
        } else if let arenaAnnotation = annotation as? Arena {
            coordinator?.showSubmitRaid(for: arenaAnnotation)
        }
    }
}

extension MapViewController: PushManagerDelegate {
    func didReceivePushNotification(with title: String, message: String, coordinate: CLLocationCoordinate2D) {
        let banner = NotificationBanner(title: title, subtitle: message.replacingOccurrences(of: "\n", with: ", "), style: .info)
        banner.show()
        
        mapRegionFromPush = MKCoordinateRegion(center: coordinate,
                                               latitudinalMeters: 200,
                                               longitudinalMeters: 200)
        mapView.setRegion(mapRegionFromPush!, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.mapRegionFromPush = nil
        }
    }
}

extension MapViewController: ClusterManagerDelegate {
    
    func cellSize(for zoomLevel: Double) -> Double {
        return 0 // default
    }
    
    func shouldClusterAnnotation(_ annotation: MKAnnotation) -> Bool {
        return true
    }
}

extension MKMapView {
    func annotationView(annotation: MKAnnotation?, reuseIdentifier: String) -> MKAnnotationView {
        let annotationView = self.annotationView(of: CountClusterAnnotationView.self, annotation: annotation, reuseIdentifier: reuseIdentifier)
        annotationView.countLabel.backgroundColor = .orange
        return annotationView
    }
}

extension MKMapView {
    func annotationView<T: MKAnnotationView>(of type: T.Type, annotation: MKAnnotation?, reuseIdentifier: String) -> T {
        guard let annotationView = dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? T else {
            return type.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        }
        annotationView.annotation = annotation
        return annotationView
    }
}
