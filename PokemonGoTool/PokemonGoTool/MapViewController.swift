
import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, LocationManagerDelegate {

    @IBOutlet private var mapView: MKMapView!
    private var locationManager = LocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        zoomToUserLocation()
    }
    
    func zoomToUserLocation() {
        if let userLocation = locationManager.currentLocation {
            let viewRegion = MKCoordinateRegion(center: userLocation.coordinate,
                                                latitudinalMeters: 1500,
                                                longitudinalMeters: 1500)
            mapView.setRegion(viewRegion, animated: true)
        }
    }
    
    func didFindInitialUserLocation() {
        zoomToUserLocation()
    }
}
