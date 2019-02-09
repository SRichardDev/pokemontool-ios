
import UIKit
import MapKit
import NotificationBannerSwift

class MapViewController: UIViewController, MKMapViewDelegate, StoryboardInitialViewController {
    
    weak var coordinator: MainCoordinator?
    var locationManager: LocationManager!
    var firebaseConnector: FirebaseConnector!
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet var settingsButtonsView: UIView!
    @IBOutlet var backgroundLabel: UILabel!
    private var polygon: MKPolygon?
    private var allAnnotations = [PokestopPointAnnotation]()
    private var geohashWindow: GeohashWindow?
    private var selectedGeohashes = [String]()
    private var isGeoashSelectionMode = false
    private var currentlyShowingLabels = true
    private var mapRegionFromPush: MKCoordinateRegion?
    
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
        removeAnnotationIfNeeded()
        
        //TODO: Fix crash when tilting map. Do adding/removing annotations on main thread
        mapView.removeOverlays(mapView.overlays)
        
        let mapRect = mapView.visibleMapRect
        geohashWindow = GeohashWindow(topLeftCoordinate: MapRectUtility.getNorthWestCoordinate(in: mapRect),
                                      topRightCoordiante: MapRectUtility.getNorthEastCoordinate(in: mapRect),
                                      bottomLeftCoordinated: MapRectUtility.getSouthWestCoordinate(in: mapRect),
                                      bottomRightCoordiante: MapRectUtility.getSouthEastCoordinate(in: mapRect))
        
        geohashWindow?.geohashMatrix.forEach { lineArray in
            lineArray.forEach { geohashBox in
                addPolyLine(for: geohashBox)
                firebaseConnector.loadPokestops(for: geohashBox.hash)
                firebaseConnector.loadArenas(for: geohashBox.hash)
            }
        }
        changeAnnotationLabelVisibility()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
        let annotationView = AnnotationView.prepareFor(mapView: mapView,
                                                       annotation: annotation,
                                                       showLabel: currentlyShowingLabels)
        annotationView?.delegate = self
        return annotationView
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

    
    func zoomToUserLocation(animated: Bool = false) {
        if let userLocation = locationManager.currentUserLocation {
            let viewRegion = MKCoordinateRegion(center: userLocation.coordinate,
                                                latitudinalMeters: 1000,
                                                longitudinalMeters: 1000)
            mapView.setRegion(viewRegion, animated: animated)
        }
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
    
    @IBAction func longPressOnMap(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            let viewModel = SubmitViewModel(firebaseConnector: firebaseConnector, coordinate: locationOnMap)
            coordinator?.showSubmitPokestopAndArena(for: viewModel)
        }
    }
    
    @IBAction func tappedMap(_ sender: UITapGestureRecognizer) {
        if isGeoashSelectionMode {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            let geohash = Geohash.encode(latitude: locationOnMap.latitude, longitude: locationOnMap.longitude)
            firebaseConnector.subscribeForPush(for: geohash)
            addPolyLine(for: Geohash.geohashbox(geohash))
        }
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
    
    private func zoomToLocationFromPushIfNeeded() {
        guard let mapRegionFromPush = mapRegionFromPush else {return}
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.mapView.setRegion(mapRegionFromPush, animated: true)
            self.mapRegionFromPush = nil
        }
    }
    
    private func togglePushRegistrationMode() {
        self.isGeoashSelectionMode = !self.isGeoashSelectionMode
        if self.isGeoashSelectionMode {
            let banner = NotificationBanner(title: "Push Registrierung",
                                            subtitle: "Wähle den Bereich aus für den du Benachrichtigt werden möchtest.",
                                            style: .info)
            banner.show()
        }
    }
    
    private func changeMapType() {
        let mapType = mapView.mapType
        if mapType == .standard {
            backgroundLabel.text = "Hybrid Karte"
        } else if mapType == .hybrid {
            backgroundLabel.text = "Satelliten Karte"
        } else if mapType == .satellite {
            backgroundLabel.text = "Standard Karte"
        }
        
        view.backgroundColor = UIColor.random()
        UIView.animate(withDuration: 0.6, animations: {
            self.mapView.alpha = 0
        }, completion: { _ in
            let mapType = self.mapView.mapType
            if mapType == .standard {
                self.mapView.mapType = .hybrid
            } else if mapType == .hybrid {
                self.mapView.mapType = .satellite
            } else if mapType == .satellite {
                self.mapView.mapType = .standard
            }
            
            UIView.animate(withDuration: 0.6, animations: {
                self.mapView.alpha = 1
            })
        })
    }
    
    private func setupMapButtonsMenu() {
        let locateButton = UIButton()
        locateButton.setImage(UIImage(named: "mapMenuLocate"), for: .normal)
        locateButton.addAction { [weak self] in
            self?.zoomToUserLocation(animated: true)
            locateButton.scaleIn()
        }
        
        let changeMapTypeButton = UIButton()
        changeMapTypeButton.setImage(UIImage(named: "mapMenuMap"), for: .normal)
        changeMapTypeButton.addAction { [weak self] in
            self?.changeMapType()
            changeMapTypeButton.scaleIn()
        }
        
        let registerPushGeohashButton = UIButton()
        registerPushGeohashButton.setImage(UIImage(named: "mapMenuPush"), for: .normal)
        registerPushGeohashButton.addAction { [weak self] in
            self?.togglePushRegistrationMode()
            registerPushGeohashButton.scaleIn()
        }
        
        ButtonsStackViewController.embed(in: settingsButtonsView,
                                         in: self,
                                         with: [registerPushGeohashButton,
                                                changeMapTypeButton,
                                                locateButton])
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
    }
}
