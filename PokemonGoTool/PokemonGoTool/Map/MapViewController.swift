
import UIKit
import MapKit
import NotificationBannerSwift

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
    var isGeoashSelectionMode = false
    var currentlyShowingLabels = true
    var mapRegionFromPush: MKCoordinateRegion?
    
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
        for annotation in annotations {
            if let pokestopAnnotation = annotation as? Pokestop {
                let annotation = PokestopPointAnnotation(pokestop: pokestopAnnotation, quests: firebaseConnector?.quests)
                addAnnotationIfNeeded(annotation)
            } else if let arenaAnnotation = annotation as? Arena {
                let annotation = ArenaPointAnnotation(arena: arenaAnnotation)
                addAnnotationIfNeeded(annotation)
            }
        }
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
            mapView.annotations.forEach { annotationOnMap in
                guard let annotationOnMap = annotationOnMap as? ArenaPointAnnotation else { return }
                if annotationOnMap.arena.id == arenaAnnotation.arena.id {
                    arenaFound = true
                }
            }
            if !arenaFound {
                mapView.addAnnotation(annotation)
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
    
    func showInfoDetail(for annotation: Annotation) {
        if let pokestopAnnotation = annotation as? Pokestop {
//            guard let pokestop = firebaseConnector.pokestops.first(where: { $0.id == pokestopAnnotation.id }) else { return }
            coordinator?.showPokestopDetails(for: pokestopAnnotation)
        } else if let arenaAnnotation = annotation as? Arena {

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
    }
}
