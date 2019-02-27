
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
    var hatchTimer: Timer?
    var timeLeftTimer: Timer?
    var timerIsOn = false
    var hasActiveRaid: Bool {
        get {
            return !(arena.raid?.isExpired ?? true)
        }
    }
    
    var isRaidbossActive: Bool {
        get {
            return arena.raid?.hasHatched ?? false
        }
    }
    
    var participants: [User]? {
        get {
            return arena.raid?.raidMeetup?.participants
        }
    }
    
    var image: UIImage? {
        get {
            return arena.raid?.image
        }
    }
    
    init(arena: Arena, firebaseConnector: FirebaseConnector) {
        self.arena = arena
        self.firebaseConnector = firebaseConnector
        self.coordinate = CLLocationCoordinate2D(latitude: arena.latitude, longitude: arena.longitude)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.current

        guard let raid = arena.raid else { return }

        if raid.isSubmittedBeforeHatchTime {
            startHatchTimer()
        } else {
            startTimeLeftTimer()
        }
    }
    
    func startHatchTimer() { 
        guard let raid = arena.raid else { return }
        guard let date = raid.hatchDate else { return }
        hatchTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            if self.isTimeUp(for: date) {
                self.startTimeLeftTimer()
                self.hatchTimer?.invalidate()
                return
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            dateFormatter.locale = Locale.current
            let dateString = dateFormatter.string(from: raid.hatchDate ?? Date())
            self.timeLeft = "Schlüpft in:\n\(self.formattedCountDown(for: date))\n\(dateString)"
            
            DispatchQueue.main.async {
                self.delegate?.didUpdateTimeLeft(self.timeLeft!)
            }
        })
    }
    
    func startTimeLeftTimer() {
        guard let raid = arena.raid else { return }
        guard let date = raid.endDate else { fatalError() }
        timeLeftTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            if self.isTimeUp(for: date) {
                self.showTimeUp()
                self.timeLeftTimer?.invalidate()
                return
            }
            self.timeLeft = "Läuft noch:\n\(self.formattedCountDown(for: date))"
            
            DispatchQueue.main.async {
                self.delegate?.didUpdateTimeLeft(self.timeLeft!)
            }
        })
    }
    
    func showTimeUp() {
        self.timeLeft = "Raid bereits abgelaufen"
        DispatchQueue.main.async {
            self.delegate?.didUpdateTimeLeft(self.timeLeft!)
        }
    }
    
    private func isTimeUp(for date: Date) -> Bool {
        let timerInterval = date.timeIntervalSince(Date())
        let time = NSInteger(timerInterval)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        return seconds <= 0 && minutes <= 0 && hours <= 0
    }
    
    private func formattedCountDown(for date: Date) -> String {
        let timerInterval = date.timeIntervalSince(Date())
        let time = NSInteger(timerInterval)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        return String(format: "%0.2d : %0.2d : %0.2d", hours, minutes, seconds)
    }
}
