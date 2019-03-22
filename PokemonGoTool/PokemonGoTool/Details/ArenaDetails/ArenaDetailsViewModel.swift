
import MapKit
import Firebase
import CodableFirebase

enum ArenaDetailsUpdateType {
    case meetupChanged
    case timeLeftChanged(_ timeLeft: String?)
}

protocol ArenaDetailsDelegate: class {
    func update(of type: ArenaDetailsUpdateType)
}

class ArenaDetailsViewModel {
    
    var firebaseConnector: FirebaseConnector
    weak var delegate: ArenaDetailsDelegate?
    var arena: Arena {
        didSet {
            guard let meetupId = arena.raid?.raidMeetupId else { return }
            firebaseConnector.observeRaidMeetup(for: meetupId)
        }
    }
    var meetup: RaidMeetup? {
        didSet {
            
        }
    }
    var coordinate: CLLocationCoordinate2D!
    var timeLeft: String?
    var hatchTimer: Timer?
    var timeLeftTimer: Timer?
    var timerIsOn = false
    
    var title: String {
        get {
            return isRaidExpired ? arena.name : arena.raid?.raidBoss?.name ?? "Level \(arena.raid?.level ?? 0) Raid"
        }
    }
    
    var participateButtonTitle: String {
        get {
            return isUserParticipating ? "Abmelden" : "Teilnehmen"
        }
    }
    
    var isUserParticipating: Bool {
        get {
            guard let userId = firebaseConnector.user?.id else {return false}
            return self.participants[userId] != nil
        }
    }
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
    
    var isRaidExpired: Bool {
        get {
            return arena.raid?.isExpired ?? true
        }
    }
    
    var hasActiveMeetup: Bool {
        get {
            return arena.raid?.raidMeetupId != nil && participants.count > 0 && !(arena.raid?.isExpired ?? true)
        }
    }
    
    var participants = [String: User]()
    
    var raidBossImage: UIImage? {
        get {
            return arena.raid?.image
        }
    }
    
    var arenaImage: UIImage {
        get {
            return arena.isEX ? UIImage(named: "arenaEX")! : UIImage(named: "arena")!
        }
    }
    
    init(arena: Arena, firebaseConnector: FirebaseConnector) {
        self.arena = arena
        self.firebaseConnector = firebaseConnector
        self.coordinate = CLLocationCoordinate2D(latitude: arena.latitude, longitude: arena.longitude)

        firebaseConnector.raidMeetupDelegate = self

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

        guard let meetupId = arena.raid?.raidMeetupId else { return }
        firebaseConnector.observeRaidMeetup(for: meetupId)
    }
        
    func userTappedParticipate() {
        if !isUserParticipating {
            guard let raid = arena.raid else { fatalError() }
            self.arena = firebaseConnector.userParticipates(in: raid, for: &arena)
        } else {
            firebaseConnector.userCanceled(in: meetup!)
            print("User canceled meetup")
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
            self.timeLeft = "🥚 → 🐉\n\(self.formattedCountDown(for: date))\n\(dateString)"
            
            DispatchQueue.main.async {
                self.delegate?.update(of: .timeLeftChanged(self.timeLeft))
            }
        })
        hatchTimer?.fire()
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
            self.timeLeft = "🐉 → ❌\n\(self.formattedCountDown(for: date))"
            
            DispatchQueue.main.async {
                self.delegate?.update(of: .timeLeftChanged(self.timeLeft))
            }
        })
        timeLeftTimer?.fire()
    }
    
    func showTimeUp() {
        self.timeLeft = "Raid bereits abgelaufen"
        DispatchQueue.main.async {
            self.delegate?.update(of: .timeLeftChanged(self.timeLeft))
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

extension ArenaDetailsViewModel: RaidMeetupDelegate {

    func didUpdateRaidMeetup(_ raidMeetup: RaidMeetup) {
        self.participants.removeAll()
        self.meetup = raidMeetup
        guard let userIds = raidMeetup.participants?.values.makeIterator() else {
            DispatchQueue.main.async {
                self.delegate?.update(of: .meetupChanged)
            }
            return
        }

        for userId in userIds {
            firebaseConnector.loadUser(for: userId) { user in
                self.participants[user.id] = user
                DispatchQueue.main.async {
                    self.delegate?.update(of: .meetupChanged)
                }
            }
        }
    }
}
