
import MapKit


protocol MapTypeSwitchable {
    func changeMapType()
    var mapView: MKMapView! {get set}
}

extension MKMapType {
    var description: String {
        get {
            switch self {
            case .standard:
                return "Standard Karte"
            case .mutedStandard:
                return "Standard Karte"
            case .satellite:
                return "Satelliten Karte"
            case .hybrid:
                return "Hybrid Karte"
            case .satelliteFlyover:
                return "Satelliten 3D Karte"
            case .hybridFlyover:
                return "Satelliten 3D Karte"
            @unknown default:
                return ""
            }
        }
    }
}

extension MapTypeSwitchable where Self: UIViewController {
    
    func changeMapType() {
        let mapType = self.mapView.mapType
        
        if mapType == .mutedStandard {
            self.mapView.mapType = .hybrid
        } else if mapType == .hybrid {
            self.mapView.mapType = .satellite
        } else if mapType == .satellite {
            self.mapView.mapType = .satelliteFlyover
        } else if mapType == .satelliteFlyover {
            self.mapView.mapType = .mutedStandard
        }
        
        NotificationBannerManager.shared.show(.mapTypeChanged(mapType: self.mapView.mapType))
    }
}

