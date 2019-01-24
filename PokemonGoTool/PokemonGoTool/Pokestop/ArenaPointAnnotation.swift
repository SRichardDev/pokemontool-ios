import UIKit
import MapKit

class ArenaPointAnnotation: MKPointAnnotation {
    var arena: Arena!
    var imageName = "arena"
    var geohash: String {
        get {
            return Geohash.encode(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
    }
    
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init()
        self.coordinate = coordinate
    }
    
    convenience init(arena: Arena) {
        self.init()
        self.arena = arena
        coordinate = CLLocationCoordinate2D(latitude: arena.latitude, longitude: arena.longitude)
    }
}
