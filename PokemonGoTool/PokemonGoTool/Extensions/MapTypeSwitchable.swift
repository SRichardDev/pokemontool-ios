
import MapKit


protocol MapTypeSwitchable {
    func changeMapTypeAnimated()
    var mapView: MKMapView! {get set}
    var backgroundLabel: UILabel! {get set}
}

extension MapTypeSwitchable where Self: UIViewController {
    
    func changeMapTypeAnimated() {
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
}

