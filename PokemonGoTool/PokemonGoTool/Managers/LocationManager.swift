
import Foundation
import CoreLocation

protocol LocationManagerDelegate: class {
    func didFindInitialUserLocation()
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    public weak var delegate: LocationManagerDelegate?
    private var locationManager: CLLocationManager!
    private var initialUserLocationWasSet = false
    private(set) var currentUserLocation: CLLocation? {
        didSet {
            if !initialUserLocationWasSet {
                initialUserLocationWasSet = true
                delegate?.didFindInitialUserLocation()
            }
        }
    }
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
//            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentUserLocation = locations.sorted { $0.horizontalAccuracy < $1.horizontalAccuracy }.first
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
        }
    }
}
