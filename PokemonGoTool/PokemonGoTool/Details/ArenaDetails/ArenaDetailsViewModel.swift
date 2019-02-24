
import MapKit

protocol RaidTimeLeftDelegate: class {
    func didUpdateTimeLeft(_ string: String)
}

class ArenaDetailsViewModel {
    
    var firebaseConnector: FirebaseConnector
    weak var delegate: RaidTimeLeftDelegate?
    var arena: Arena
    var coordinate: CLLocationCoordinate2D!
    var timeLeft: String?
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
    
        guard let raid = arena.raid else { return }
        guard let timestampDate = arena.raid?.date else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.current
        
        
        var refDate = Date()
        
        if raid.hasHatched {
            guard let timeLeft = raid.timeLeft else { return }
            let activeRaidTimeLeftDate = timestampDate.addingTimeInterval(timeLeft.double * 60.0)
            refDate = activeRaidTimeLeftDate
            let newDateString = dateFormatter.string(from: activeRaidTimeLeftDate)
            print(newDateString)
        } else {
            guard let hatchTime = raid.hatchTime else { return }
            let hoursAndMinutesUntilHatch = hatchTime.components(separatedBy: ":")
            let hatchDate = Calendar.current.date(bySettingHour: Int(hoursAndMinutesUntilHatch[0]) ?? 0,
                                                  minute: Int(hoursAndMinutesUntilHatch[1]) ?? 0,
                                                  second: 0,
                                                  of: Date())!
            refDate = hatchDate
            let hatchTimeDateString = dateFormatter.string(from: hatchDate)
            print(hatchTimeDateString)
        }
        
        

        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in

            let timerInterval = refDate.timeIntervalSince(Date())
            let time = NSInteger(timerInterval)
            let seconds = time % 60
            let minutes = (time / 60) % 60
            let hours = (time / 3600)
            
            if raid.hasHatched {
                self.timeLeft = String(format: "Läuft noch:\n%0.2d : %0.2d : %0.2d",hours ,minutes ,seconds)
            } else {
                self.timeLeft = String(format: "Schlüpft in:\n%0.2d : %0.2d : %0.2d",hours ,minutes ,seconds)
            }
            
//            if !raid.isActiveAndRunning {
//                self.timeLeft = "Raid bereits abgelaufen"
//                self.timer?.invalidate()
//            } else {
//
//            }
            
            DispatchQueue.main.async {
                self.delegate?.didUpdateTimeLeft(self.timeLeft ?? "")
            }
        })
        
    }
}
