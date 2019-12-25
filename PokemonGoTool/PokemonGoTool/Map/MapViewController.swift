
import UIKit
import MapKit
import Cluster

class MapViewController: UIViewController, MKMapViewDelegate, StoryboardInitialViewController, MapTypeSwitchable, PoiSubmissable, BottomMenuShowable, GeohashRegisterable, MapRegionSetable {
    
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
    let messageView = MessageView()
    private let arenaConnector = ArenaConnector()
    private let pokestopConnector = PokestopConnector()
    
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
        PushManager.shared.delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = .mutedStandard
        mapView.pointOfInterestFilter = MKPointOfInterestFilter(including: [.park])
        zoomToUserLocation()
        setupMapButtonsMenu()
        processLatestPushIfNeeded()
        messageView.addToTopMiddle(in: self.view)
        
        arenaConnector.didAddArenaCallback = { arena in
            DispatchQueue.global().async {
                let annotation = ArenaPointAnnotation(arena: arena)
                self.manager.add(annotation)
                DispatchQueue.main.async {
                    self.manager.reload(mapView: self.mapView)
                }
            }
        }

        arenaConnector.didUpdateArenaCallback = { arena in
            let foundAnnotation = self.manager.annotations.first { annotation in
                if let arenaAnnotation = annotation as? ArenaPointAnnotation {
                    return arenaAnnotation.arena?.id == arena.id
                }
                return false
            }
            if let foundUnwrappedAnnotation = foundAnnotation {
                self.manager.remove(foundUnwrappedAnnotation)
            }
            let updatedAnnotation = ArenaPointAnnotation(arena: arena)
            self.manager.add(updatedAnnotation)
            self.manager.reload(mapView: self.mapView)
        }
        
        pokestopConnector.didAddPokestopCallback = { pokestop in
            DispatchQueue.global().async {
                let annotation = PokestopPointAnnotation(pokestop: pokestop, quests: self.firebaseConnector?.quests)
                self.manager.add(annotation)
                DispatchQueue.main.async {
                    self.manager.reload(mapView: self.mapView)
                }
            }
        }
        
        pokestopConnector.didUpdatePokestopCallback = { pokestop in
            let foundAnnotation = self.manager.annotations.first { annotation in
                if let arenaAnnotation = annotation as? PokestopPointAnnotation {
                    return arenaAnnotation.pokestop?.id == pokestop.id
                }
                return false
            }
            if let foundUnwrappedAnnotation = foundAnnotation {
                self.manager.remove(foundUnwrappedAnnotation)
            }
            let updatedAnnotation = PokestopPointAnnotation(pokestop: pokestop, quests: self.firebaseConnector?.quests)
            self.manager.add(updatedAnnotation)
            self.manager.reload(mapView: self.mapView)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadAnnotations),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !firebaseConnector.isSignedIn {
            NotificationBannerManager.shared.show(.notLoggedIn)
        }
        
        if AppSettings.filterSettingsChanged {
            reloadAnnotations()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        zoomToLocationFromPushIfNeeded()
        
        if AppSettings.isFilterActive {
            messageView.show()
        } else {
            messageView.hide()
        }
        
        guard let user = firebaseConnector.user else { return }
        if firebaseConnector.isSignedIn && !user.isRegisteredForGeohashes {
            let alert = UIAlertController(title: "Du bist noch nicht für Push Nachrichten registriert!",
                                          message: "Um den vollen Funktionsumfang der App zu erleben musst du dir einen Bereich auswählen, für den du Benachrichtigt werden möchtest.\n\nUm dich zu registrieren tippe bitte auf das Zahnrad unten rechts und dann auf den Pin mit dem Haken drin.",
                                          preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(ok)
            present(alert, animated:true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        endPoiSubmission()
        endGeohashRegistration()
        moveMapMenu(ConstraintConstants.mapMenuOrigin)
    }
    
    @objc
    func reloadAnnotations() {
        AppSettings.filterSettingsChanged = false
        arenaConnector.clear()
        pokestopConnector.clear()
        manager.remove(manager.annotations)
        manager.reload(mapView: self.mapView)
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
                pokestopConnector.loadPokestops(for: geohashBox.hash)
                arenaConnector.loadArenas(for: geohashBox.hash)
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
        
        if let annotation = annotation as? ArenaPointAnnotation,
            let arena = annotation.arena {
            firebaseConnector.clearRaidIfExpired(for: arena)
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
        let showLabels = mapView.camera.altitude < 1500.0
        
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
    
    func didReceivePush(_ push: PushNotification) {
        
        if let push = push as? ArenaPushNotification {
            openArenaForPush(push)
        }
    }
    
    func openArenaForPush(_ push: ArenaPushNotification) {
        setMapRegion(distance: 200, coordinate: push.coordinate)
        arenaConnector.arena(in: push.geohash, for: push.arenaId) { [weak self] arena in
            guard let arena = arena else { return }
            guard arena.raid?.isActive ?? false else { self?.openArenaForPush(push); return }
            self?.coordinator?.showArenaDetails(for: arena)
        }
    }
    
    func processLatestPushIfNeeded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            guard let push = PushManager.shared.latestPushNotification else { return }

            if let push = push as? ArenaPushNotification {
                self.openArenaForPush(push)
            }
        }
    }
}

extension MapViewController: ClusterManagerDelegate {
    
    func shouldClusterAnnotation(_ annotation: MKAnnotation) -> Bool {
        
        if let arenaAnnotation = annotation as? ArenaPointAnnotation {
            return arenaAnnotation.arena?.raid?.isExpired ?? true
        }
        
        return true
    }
}

extension MKMapView {
    func annotationView(annotation: MKAnnotation?, reuseIdentifier: String) -> MKAnnotationView {
        let annotationView = self.annotationView(of: CountClusterAnnotationView.self,
                                                 annotation: annotation,
                                                 reuseIdentifier: reuseIdentifier)
        annotationView.countLabel.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.2)
        annotationView.countLabel.textColor = .lightGray
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
