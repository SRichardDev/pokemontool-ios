
import MapKit

class PokestopDetailsViewModel {
    
    var coordinate: CLLocationCoordinate2D!
    var firebaseConnector: FirebaseConnector
    var pokestop: Pokestop

    init(pokestop: Pokestop, firebaseConnector: FirebaseConnector) {
        self.pokestop = pokestop
        self.firebaseConnector = firebaseConnector
        self.coordinate = CLLocationCoordinate2D(latitude: pokestop.latitude, longitude: pokestop.longitude)
    }
    
    var rewardImageName: String {
        let quest = firebaseConnector.quests.first(where: {$0.id == pokestop.quest?.definitionId})
        return quest?.imageName ?? "??"
    }
}
