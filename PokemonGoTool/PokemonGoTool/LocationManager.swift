
import Foundation
import CoreLocation

protocol LocationManagerDelegate: class {
    func didFindInitialUserLocation()
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    public weak var delegate: LocationManagerDelegate?
    private var locationManager: CLLocationManager!
    private var userLocationWasSet = false
    private(set) var currentLocation: CLLocation? {
        didSet {
            if !userLocationWasSet {
                userLocationWasSet = true
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
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.sorted { $0.horizontalAccuracy < $1.horizontalAccuracy }.first
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
        }
    }
}
