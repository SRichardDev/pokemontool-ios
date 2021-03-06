
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

class SubmitViewModel: ViewModel {
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
    
    var name: String = ""
    var coordinate: CLLocationCoordinate2D!
    
    var submitContent: SubmitContent {
        get {
            return SubmitContent(location: coordinate, name: name, submitType: submitType)
        }
    }
    var submitType: SubmitType = .pokestop
    var firebaseConnector: FirebaseConnector
    
    init(firebaseConnector: FirebaseConnector, coordinate: CLLocationCoordinate2D) {
        self.firebaseConnector = firebaseConnector
        self.coordinate = coordinate
    }
    
    func submit() {
        guard let name = submitContent.name else { return }
        guard let coordinate = submitContent.location else { return }
        guard let submitType = submitContent.submitType else { return }
        guard let userId = firebaseConnector.user?.id else { return }
        switch submitType {
        case .pokestop:
            let pokestop = Pokestop(name: name,
                                    latitude: coordinate.latitude,
                                    longitude: coordinate.longitude,
                                    submitter: userId)
            firebaseConnector.savePokestop(pokestop)
        case .arena(let isEX):
            let arena = Arena(name: name,
                              latitude: coordinate.latitude,
                              longitude: coordinate.longitude,
                              submitter: userId,
                              isExArena: isEX ?? false)
            firebaseConnector.saveArena(arena)
        }
    }
}
