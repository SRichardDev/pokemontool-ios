
import MapKit

class PokestopDetailsViewModel {
    
    var coordinate: CLLocationCoordinate2D!
    var firebaseConnector: FirebaseConnector
    var pokestop: Pokestop

    var hasActiveQuest: Bool {
        get {
            return pokestop.quest?.isActive ?? false
        }
    }
    
    var questDefinition: QuestDefinition? {
        return firebaseConnector.quests.first(where: {$0.id == pokestop.quest?.definitionId})
    }
    
    init(pokestop: Pokestop, firebaseConnector: FirebaseConnector) {
        self.pokestop = pokestop
        self.firebaseConnector = firebaseConnector
        self.coordinate = CLLocationCoordinate2D(latitude: pokestop.latitude, longitude: pokestop.longitude)
    }
    
    func pokestopSubmitterName(completion: @escaping (String) -> ()) {
        firebaseConnector.user(for: pokestop.submitter, completion: { userData in
            guard let trainerName = userData.trainerName else { return }
            completion(trainerName)
        })
    }
    
    func questSubmitterName(completion: @escaping (String) -> ()) {
        guard let submitter = pokestop.quest?.submitter else { return }
        firebaseConnector.user(for: submitter, completion: { userData in
            guard let trainerName = userData.trainerName else { return }
            completion(trainerName)
        })
    }
}
