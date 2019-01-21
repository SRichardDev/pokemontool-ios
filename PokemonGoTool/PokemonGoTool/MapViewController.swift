
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, AppModuleAccessible {
    
    @IBOutlet private var mapView: MKMapView!
    var locationManager: LocationManager!
    var firebaseConnector: FirebaseConnector!
    private var polygon: MKPolygon?
    private var allAnnotations = [PokestopPointAnnotation]()
    let geohashWindow = GeohashWindow()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.delegate = self
        firebaseConnector.delegate = self
        zoomToUserLocation()
    }
    
    func zoomToUserLocation() {
        if let userLocation = locationManager.currentUserLocation {
            let viewRegion = MKCoordinateRegion(center: userLocation.coordinate,
                                                latitudinalMeters: 1500,
                                                longitudinalMeters: 1500)
            mapView.setRegion(viewRegion, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        let centerGeohash = Geohash.encode(latitude: center.latitude, longitude: center.longitude)
        
        guard centerGeohash != geohashWindow.currentGeohash else { return }
        print("Geohash changed to: \(centerGeohash)")
        geohashWindow.currentGeohash = centerGeohash
        
        removeAnnotationIfNeeded()
        mapView.removeOverlays(mapView.overlays)
        geohashWindow.neighborGeohashes?.forEach { firebaseConnector.loadPokestops(for: $0) }
        firebaseConnector.loadPokestops(for: geohashWindow.currentGeohash)
        
        let hashes = geohashWindow.neighborGeohashes
        hashes?.forEach { addPolyLine(for: Geohash.geohashbox($0)) }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: polyline)
            polylineRenderer.strokeColor = UIColor.orange.withAlphaComponent(0.5)
            polylineRenderer.lineWidth = 1
            return polylineRenderer
        } else {
            let renderer = MKPolygonRenderer(polygon: polygon!)
            renderer.fillColor = UIColor.green.withAlphaComponent(0.2)
            return renderer
        }
    }
    
    func addPolyLine(for geohashBox: GeohashBox?) {
        guard let geohashBox = geohashBox else { return }
        let polyLine = MKPolyline.polyline(for: geohashBox)
        let polygon = MKPolygon.polygon(for: geohashBox)
        self.polygon = polygon
        mapView.addOverlay(polyLine)
        mapView.addOverlay(polygon)
    }
    
    @IBAction func longPressOnMap(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            addAnnotation(for: locationInView)
        }
    }
    
    @IBAction func tappedMap(_ sender: UITapGestureRecognizer) {
        let locationInView = sender.location(in: mapView)
        let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
        let geoHash = Geohash.encode(latitude: locationOnMap.latitude, longitude: locationOnMap.longitude)
        addPolyLine(for: Geohash.geohashbox(geoHash))
    }
    
    func addAnnotation(for locationInView: CGPoint) {
        let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
        let pokestop = Pokestop(name: "Test",
                                latitude: locationOnMap.latitude,
                                longitude: locationOnMap.longitude,
                                id: nil,
                                quest: nil)
        firebaseConnector.savePokestop(pokestop)
        let feedback = UIImpactFeedbackGenerator()
        feedback.impactOccurred()
    }
}

extension MapViewController: FirebaseDelegate {
    func didUpdateQuests() {
        firebaseConnector.pokestops.forEach {
            let annotation = PokestopPointAnnotation(pokestop: $0)
            addAnnotationIfNeeded(annotation)
        }
    }
}

extension MapViewController: LocationManagerDelegate {
    
    func didFindInitialUserLocation() {
        zoomToUserLocation()
    }
}

extension MapViewController {
    
    func addAnnotationIfNeeded(_ annotation: PokestopPointAnnotation) {
        DispatchQueue.main.async {
            
            var pokestopFound = false
            
            self.mapView.annotations.forEach { annotationOnMap in
                guard let annotationOnMap = annotationOnMap as? PokestopPointAnnotation else { return }
                if annotationOnMap.pokestop.id == annotation.pokestop.id {
                    pokestopFound = true
                }
            }
            
            if !pokestopFound {
                self.mapView.addAnnotation(annotation)
                print("Annotation added")
            }
        }
    }
    
    func removeAnnotationIfNeeded() {
        mapView.annotations.forEach {
            guard let annotation = $0 as? PokestopPointAnnotation else { return }
            if annotation.geohash != geohashWindow.currentGeohash {
                let annotationGeohash = annotation.geohash
                var foundAnnotationGeohashInNeighbor = false
                
                geohashWindow.neighborGeohashes(for: annotationGeohash).forEach { neighborGeohash in
                    if neighborGeohash == geohashWindow.currentGeohash {
                        foundAnnotationGeohashInNeighbor = true
                    }
                }
                if !foundAnnotationGeohashInNeighbor {
                    print("Removed annotation")
                    mapView.removeAnnotation(annotation)
                }
            }
        }
    }
}
