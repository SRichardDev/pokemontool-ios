import UIKit
import MapKit

class ArenaPointAnnotation: MKPointAnnotation, GeohashStringRepresentable {
    
    var arena: Arena?
    var raidEggImageName = "level_5"
    
    var geohash: String {
        get {
            return Geohash.encode(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
    }
    
    static func == (lhs: ArenaPointAnnotation, rhs: ArenaPointAnnotation) -> Bool {
        return (lhs.arena == rhs.arena)
    }
    
    //Init for submitting arena
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init()
        self.coordinate = coordinate
    }
    
    convenience init(arena: Arena) {
        self.init()
        self.arena = arena
        coordinate = CLLocationCoordinate2D(latitude: arena.latitude, longitude: arena.longitude)

        guard let raid = arena.raid else { return }
        if !raid.isExpired {
            raidEggImageName = "level_\(raid.level)"
        }
    }
}
