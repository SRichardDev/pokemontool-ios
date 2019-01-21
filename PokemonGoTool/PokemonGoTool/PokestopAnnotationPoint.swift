
import UIKit
import MapKit

class PokestopPointAnnotation: MKPointAnnotation {
    var pokestop: Pokestop!
    var geohash: String {
        get {
            return Geohash.encode(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
    }

    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init()
        self.coordinate = coordinate
    }
    
    convenience init(pokestop: Pokestop) {
        self.init()
        self.pokestop = pokestop
        coordinate = CLLocationCoordinate2D(latitude: pokestop.latitude, longitude: pokestop.longitude)
    }
}
