
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet private var mapView: MKMapView!
    private var locationManager = LocationManager()
    private var firebaseConnector: FirebaseConnector!
    private var currentGeohash = ""
    private var polygon: MKPolygon?
    private var allAnnotations = [PokestopPointAnnotation]()
    private var neighborGeohashes: [String]? {
        get {
            return Geohash.neighbors(currentGeohash)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        mapView.delegate = self
        firebaseConnector = FirebaseConnector()
        firebaseConnector.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        
        guard centerGeohash != currentGeohash else { return }
        print("Geohash changed to: \(centerGeohash)")
        currentGeohash = centerGeohash
        
        removeAnnotationIfNeeded()
        mapView.removeOverlays(mapView.overlays)
        neighborGeohashes?.forEach { firebaseConnector.loadQuests(for: $0) }
        firebaseConnector.loadQuests(for: currentGeohash)
        addPolyLine(for: Geohash.geohashbox(currentGeohash))
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: polyline)
            polylineRenderer.strokeColor = .red
            polylineRenderer.lineWidth = 2
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
        let quest = Quest(pokestop: "Pokestop",
                          name: "Name",
                          reward: "Reward",
                          latitude: locationOnMap.latitude,
                          longitude: locationOnMap.longitude,
                          submitter: "Developer",
                          id: nil)
        firebaseConnector.saveQuest(quest)
        let feedback = UIImpactFeedbackGenerator()
        feedback.impactOccurred()
    }

}

extension MapViewController: FirebaseDelegate {
    func didUpdateQuests() {
        firebaseConnector.quests.forEach {
            let annotation = PokestopPointAnnotation(quest: $0)
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
            
            var questFound = false
            
            self.mapView.annotations.forEach { annotationOnMap in
                guard let annotationOnMap = annotationOnMap as? PokestopPointAnnotation else { return }
                if annotationOnMap.quest.id == annotation.quest.id {
                    questFound = true
                }
            }
            
            if !questFound {
                self.mapView.addAnnotation(annotation)
                print("Annotation added")
            }
        }
    }
    
    func removeAnnotationIfNeeded() {
        mapView.annotations.forEach {
            guard let annotation = $0 as? PokestopPointAnnotation else { return }
            if annotation.geohash != currentGeohash {
                let annotationGeohash = annotation.geohash
                let neighborsGeohashes = Geohash.neighbors(annotationGeohash)
                var foundAnnotationGeohashInNeighbor = false
                
                neighborsGeohashes?.forEach { neighborGeohash in
                    if neighborGeohash == currentGeohash {
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
