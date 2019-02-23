
import MapKit

protocol RaidTimeLeftDelegate: class {
    func didUpdateTimeLeft(_ string: String)
}

class ArenaDetailsViewModel {
    
    var firebaseConnector: FirebaseConnector
    weak var delegate: RaidTimeLeftDelegate?
    var arena: Arena
    var coordinate: CLLocationCoordinate2D!
    var submitDate: String?
    var timer: Timer?
    var timerIsOn = false
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
        
        if let timeStamp = arena.raid?.timestamp {
            let date = timeStamp.dateFromUnixTime()
            let dateNew = date.addingTimeInterval((arena.raid?.timeLeft?.double ?? 0) * 60.0)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            dateFormatter.locale = Locale.current
            let newDateString = dateFormatter.string(from: dateNew)
            if dateNew < Date() {
                submitDate = "Raid bereits abgelaufen"
            } else {
                submitDate = newDateString
            }
            


            
            
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
                let timerInterval = dateNew.timeIntervalSince(Date())
                let time = NSInteger(timerInterval)
                let seconds = time % 60
                let minutes = (time / 60) % 60
                let hours = (time / 3600)
                DispatchQueue.main.async {
                    self.submitDate = String(format: "%0.2d : %0.2d : %0.2d",hours,minutes,seconds)
                    self.delegate?.didUpdateTimeLeft(self.submitDate ?? "")
                }
            })
        }
    }
}
