
import MapKit

class PokestopDetailsViewModel: HeaderProvidable {
    
    var coordinate: CLLocationCoordinate2D!
    var firebaseConnector: FirebaseConnector
    var pokestop: Pokestop

    var headerTitle: String { return pokestop.name }
    var headerImage: UIImage { return pokestop.image }
    var hasActiveQuest: Bool { return pokestop.quest?.isActive ?? false }
    var hasActiveIncident: Bool { return pokestop.incident?.isActive ?? false }
    var incidentName: String { return pokestop.incident?.descripiton ?? "Unbekannt" }
    var incidentSubmitter: String { return pokestop.incident?.submitter ?? "Unbekannt" }
    
    var incidentTimeFrame: String {
        guard let incident = pokestop.incident else { return "Unbekannt"}
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale.current
        let startTime = dateFormatter.string(from: incident.start)
        let endTime = dateFormatter.string(from: incident.expiration)
        return "\(startTime) - \(endTime)"
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
        if pokestop.submitter == "System" {
            completion(pokestop.submitter)
        }
        
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
