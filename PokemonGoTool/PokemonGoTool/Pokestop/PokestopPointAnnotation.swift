
import UIKit
import MapKit

protocol GeohashStringRepresentable {
    var geohash: String { get }
}

class PokestopPointAnnotation: MKPointAnnotation, GeohashStringRepresentable {
    var pokestop: Pokestop!
    var imageName = "Pokestop"
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
