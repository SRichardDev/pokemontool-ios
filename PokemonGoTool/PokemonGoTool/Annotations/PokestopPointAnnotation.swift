
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
        self.imageName = "PokestopForGrabbing"
    }
    
    convenience init(pokestop: Pokestop, quests: [QuestDefinition]?) {
        self.init()
        self.pokestop = pokestop
        coordinate = CLLocationCoordinate2D(latitude: pokestop.latitude, longitude: pokestop.longitude)
        quests?.forEach {$0.id == pokestop.quest?.definitionId ? imageName = $0.imageName : nil}
    }
}
