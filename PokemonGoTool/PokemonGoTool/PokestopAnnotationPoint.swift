
import UIKit
import MapKit

class PokestopPointAnnotation: MKPointAnnotation {
    var quest: Quest!
    
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init()
        self.coordinate = coordinate
    }
    
    convenience init(quest: Quest) {
        self.init()
        self.quest = quest
        coordinate = CLLocationCoordinate2D(latitude: quest.latitude, longitude: quest.longitude)
    }
}
