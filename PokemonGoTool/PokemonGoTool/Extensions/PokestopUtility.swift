
import UIKit

class PokestopUtility {
    
    let pokestop: Pokestop
    
    var incidentTimeFrame: String {
        guard let incident = pokestop.incident else { return "Unbekannt"}
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale.current
        let startTime = dateFormatter.string(from: incident.start)
        let endTime = dateFormatter.string(from: incident.expiration)
        return "\(startTime) - \(endTime)"
    }
    
    init(pokestop: Pokestop) {
        self.pokestop = pokestop
    }
    
    
    func detailAnnotionString() -> String {
        if let incident = pokestop.incident, incident.isActive {
            return """
            Typ: \(incident.descripiton)
            Zeitraum: \(incidentTimeFrame)
            """
        }
        
        return "Pokéstop"
    }
    
    func detailAnnotationImage() -> UIImage {
        if let incident = pokestop.incident, incident.isActive {
            return UIImage(named: "PokestopIncidentLarge")!
        }
        return UIImage(named: "PokestopLarge")!
    }
}
