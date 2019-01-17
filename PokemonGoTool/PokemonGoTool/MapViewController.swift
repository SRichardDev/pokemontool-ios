
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    

    @IBOutlet private var mapView: MKMapView!
    private var locationManager = LocationManager()
    private var firebaseConnector: FirebaseConnector!
    private var currentGeoHash = ""
    private var polygon: MKPolygon?

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
        
        guard centerGeohash != currentGeoHash else { return }
        print("Geohash changed to: \(centerGeohash)")
        currentGeoHash = centerGeohash
        mapView.removeAnnotations(mapView.annotations)
        firebaseConnector.loadQuests(for: centerGeohash)
        addPolyLine()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: polyline)
            polylineRenderer.strokeColor = .blue
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        } else {
            let renderer = MKPolygonRenderer(polygon: polygon!)
            renderer.fillColor = UIColor.green.withAlphaComponent(0.2)
            return renderer
        }
    }
    
    func addPolyLine() {
        guard let geohashBox = Geohash.geohashbox(currentGeoHash) else { return }
        mapView.removeOverlays(mapView.overlays)
        let polyLine = MKPolyline.polyline(for: geohashBox)
        let polygon = MKPolygon.polygon(for: geohashBox)
        self.polygon = polygon
        mapView.addOverlay(polyLine)
        mapView.addOverlay(polygon)
    }
    
    @IBAction func tappedOnMap(sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            let annotation = PokestopPointAnnotation(coordinate: locationOnMap)
            let quest = Quest(name: "Foo",
                              reward: "bar",
                              latitude: locationOnMap.latitude,
                              longitude: locationOnMap.longitude,
                              submitter: "Developer")
            firebaseConnector.saveQuest(quest)
//            addAnnotation(annotation)
            let feedback = UIImpactFeedbackGenerator()
            feedback.impactOccurred()
        }
    }
}

extension MapViewController: FirebaseDelegate {
    func didUpdateQuests() {
        for quest in firebaseConnector.quests {
            let annotation = PokestopPointAnnotation(quest: quest)
            addAnnotation(annotation)
        }
    }
    
    func addAnnotation(_ annotation: MKAnnotation) {
        DispatchQueue.main.async {
            self.mapView.addAnnotation(annotation)
        }
    }
}

extension MapViewController: LocationManagerDelegate {
    
    func didFindInitialUserLocation() {
        zoomToUserLocation()
    }
}
