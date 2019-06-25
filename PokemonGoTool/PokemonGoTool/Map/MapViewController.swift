
import UIKit
import MapKit
import Cluster

class MapViewController: UIViewController, MKMapViewDelegate, StoryboardInitialViewController, MapTypeSwitchable, PoiSubmissable, BottomMenuShowable, GeohashRegisterable, MapRegionSetable, SettingsAppliable {
    
    weak var coordinator: MainCoordinator?
    var locationManager: LocationManager!
    var firebaseConnector: FirebaseConnector!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var settingsButtonsView: UIView!
    var polygon: MKPolygon?
    var allAnnotations = [PokestopPointAnnotation]()
    var geohashWindow: GeohashWindow?
    var selectedGeohashes = [String]()
    var isGeohashSelectionMode = false
    var currentlyShowingLabels = true
    var mapRegionFromPush: MKCoordinateRegion?

    var isPoiSubmissionMode = false
    var poiSubmissionAnnotation = MKPointAnnotation()

    lazy var manager: ClusterManager = {
        let manager = ClusterManager()
        manager.delegate = self
        manager.maxZoomLevel = 17
        manager.minCountForClustering = 5
        manager.clusterPosition = .average
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        firebaseConnector.delegate = self
        PushManager.shared.delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = .mutedStandard
        mapView.showsPointsOfInterest = false
        zoomToUserLocation()
        setupMapButtonsMenu()
        displayLocationFromPushIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AppSettings.filterSettingsChanged { appSettingsDidChange() }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        zoomToLocationFromPushIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        endPoiSubmission()
        endGeohashRegistration()
        moveMapMenu(ConstraintConstants.mapMenuOrigin)
    }
    
    func appSettingsDidChange() {
        manager.removeAll()
        manager.reload(mapView: mapView)
        loadData()
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        updatePoiSubmissionCoordinate(mapView.centerCoordinate)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard !isGeohashSelectionMode else { return }
        loadData()
    }
    
    func loadData() {
        let mapRect = mapView.visibleMapRect
        geohashWindow = GeohashWindow(topLeftCoordinate: MapRectUtility.getNorthWestCoordinate(in: mapRect),
                                      topRightCoordiante: MapRectUtility.getNorthEastCoordinate(in: mapRect),
                                      bottomLeftCoordinate: MapRectUtility.getSouthWestCoordinate(in: mapRect),
                                      bottomRightCoordiante: MapRectUtility.getSouthEastCoordinate(in: mapRect))
        
        geohashWindow?.geohashMatrix.forEach { lineArray in
            lineArray.forEach { geohashBox in
                firebaseConnector.loadPokestops(for: geohashBox.hash)
                firebaseConnector.loadArenas(for: geohashBox.hash)
            }
        }
        
        changeAnnotationLabelVisibility()
        manager.reload(mapView: mapView)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            guard let playerImage = ImageManager.image(named: "player") else { return nil }
            let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pin.image = playerImage.resize(scaleFactor: 0.5)
            pin.addPulsator(numPulses: 1)
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
            polylineRenderer.strokeColor = UIColor.red.withAlphaComponent(0.5)
            polylineRenderer.lineWidth = 1
            return polylineRenderer
        } else {
            let renderer = MKPolygonRenderer(polygon: polygon!)
            renderer.fillColor = UIColor.green.withAlphaComponent(0.2)
            return renderer
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        views.forEach { $0.transform = CGAffineTransform(scaleX: 0, y: 0) }
        UIView.animate(withDuration: 0.5) {
            views.forEach { $0.transform = .identity }
        }
    }
    
    func changeAnnotationLabelVisibility() {
        let showLabels = mapView.camera.altitude < 1000.0
        
        if showLabels != currentlyShowingLabels {
            currentlyShowingLabels = showLabels
            mapView.annotations.forEach { annotation in
                if let annotationView = self.mapView.view(for: annotation) as? AnnotationView {
                    annotationView.changeLabelVisibilityAnimated(showLabels)
                }
            }
        }
    }
}

extension MapViewController: FirebaseDelegate {
    
    func didUpdateArena(arena: Arena) {
        for annotationOnMap in mapView.annotations {
            if let arenaAnnotationOnMap = annotationOnMap as? ArenaPointAnnotation {
                if arenaAnnotationOnMap.arena?.id == arena.id {
                    manager.remove(annotationOnMap)
                    didAddArena(arena: arena)
                }
            }
        }
    }

    func didUpdatePokestop(pokestop: Pokestop) {
        for annotationOnMap in mapView.annotations {
            if let pokestopAnnotationOnMap = annotationOnMap as? PokestopPointAnnotation {
                if pokestopAnnotationOnMap.pokestop?.id == pokestop.id {
                    manager.remove(annotationOnMap)
                    didAddPokestop(pokestop: pokestop)
                }
            }
        }
    }
    
    func didAddArena(arena: Arena) {
        let annotation = ArenaPointAnnotation(arena: arena)
        
        if AppSettings.showArenas {
            if AppSettings.showOnlyEXArenas {
                if arena.isEX {
                    manager.add(annotation)
                    manager.reload(mapView: mapView)
                }
            } else if AppSettings.showOnlyArenasWithRaid {
                if arena.hasActiveRaid {
                    manager.add(annotation)
                    manager.reload(mapView: mapView)
                }
            } else {
                manager.add(annotation)
                manager.reload(mapView: mapView)
            }
        }
    }
    
    func didAddPokestop(pokestop: Pokestop) {
        let annotation = PokestopPointAnnotation(pokestop: pokestop, quests: firebaseConnector?.quests)
        
        if AppSettings.showPokestops {
            if AppSettings.showOnlyPokestopsWithQuest {
                if pokestop.hasActiveQuest {
                    manager.add(annotation)
                    manager.reload(mapView: mapView)
                }
            } else {
                manager.add(annotation)
                manager.reload(mapView: mapView)
            }
        }
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
            coordinator?.showPokestopDetails(for: pokestopAnnotation)
        } else if let arena = annotation as? Arena {
            coordinator?.showArenaDetails(for: arena)
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
    
    func didReceivePush() {
        displayLocationFromPushIfNeeded()
    }
    
    func displayLocationFromPushIfNeeded() {
        guard let push = PushManager.shared.latestPushNotification else { return }
        
        NotificationBannerManager.shared.show(.pushNotification,
                                              title: push.title,
                                              message: push.message.replacingOccurrences(of: "\n", with: ", "))
        setMapRegion(distance: 200, coordinate: push.coordinate)
    }
}

extension MapViewController: ClusterManagerDelegate {
    
    func shouldClusterAnnotation(_ annotation: MKAnnotation) -> Bool {
        return true
    }
}

extension MKMapView {
    func annotationView(annotation: MKAnnotation?, reuseIdentifier: String) -> MKAnnotationView {
        let annotationView = self.annotationView(of: CountClusterAnnotationView.self,
                                                 annotation: annotation,
                                                 reuseIdentifier: reuseIdentifier)
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
