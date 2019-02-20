
import MapKit

class ArenaDetailsViewModel {
    
    var firebaseConnector: FirebaseConnector
    var arena: Arena
    var coordinate: CLLocationCoordinate2D!

    var hasActiveRaid: Bool {
        get {
            return arena.raid != nil
        }
    }
    
    var participants: [User]? {
        get {
            return arena.raid?.raidMeetup?.participants
        }
    }
    
    init(arena: Arena, firebaseConnector: FirebaseConnector) {
        self.arena = arena
        self.firebaseConnector = firebaseConnector
        self.coordinate = CLLocationCoordinate2D(latitude: arena.latitude, longitude: arena.longitude)
    }
}
