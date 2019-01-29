
import Foundation
import MapKit

enum SubmitType {
    case pokestop
    case arena(isEX: Bool?)
}

struct SubmitContent {
    var location: CLLocationCoordinate2D?
    var name: String?
    var submitType: SubmitType!
}

class SubmitViewModel {
    var title: String {
        get {
            switch submitType {
            case .pokestop:
                return "Neuer Pokéstop"
            case .arena:
                return "Neue Arena"
            }
        }
    }
    
    var isPokestop: Bool {
        get {
            switch submitType {
            case .pokestop:
                return true
            default:
                return false
            }
        }
    }
    
    var submitName: String {
        get {
            if isPokestop {
                return "Pokéstop: \(submitContent.name ?? "")"
            } else {
                return "Arena: \(submitContent.name ?? "")"
            }
        }
    }
    
    var coordinate: CLLocationCoordinate2D
    var submitContent: SubmitContent!
    var submitType: SubmitType = .pokestop
    var firebaseConnector: FirebaseConnector
    
    init(firebaseConnector: FirebaseConnector, coordinate: CLLocationCoordinate2D) {
        self.firebaseConnector = firebaseConnector
        self.coordinate = coordinate
    }
    
    func submitContent(coordinate: CLLocationCoordinate2D, name: String? = nil) {
        submitContent = SubmitContent(location: coordinate, name: name, submitType: submitType)
    }
    
    func submit() {
        guard let name = submitContent?.name else { return }
        guard let coordinate = submitContent?.location else { return }
        guard let submitType = submitContent?.submitType else { return }
        guard let user = firebaseConnector.user?.trainerName else { return }
        switch submitType {
        case .pokestop:
            let pokestop = Pokestop(name: name,
                                    latitude: coordinate.latitude,
                                    longitude: coordinate.longitude,
                                    submitter: user)
            firebaseConnector.savePokestop(pokestop)
        case .arena(let isEX):
            let arena = Arena(name: name,
                              latitude: coordinate.latitude,
                              longitude: coordinate.longitude,
                              submitter: user,
                              isExArena: isEX ?? false)
            firebaseConnector.saveArena(arena)
        }
    }
}
