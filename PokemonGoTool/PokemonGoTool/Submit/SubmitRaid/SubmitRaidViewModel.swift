
import Foundation

enum UpdateType {
    case raidLevelChanged
    case raidAlreadyRunning
    case userParticipates
    case currentRaidbossesChanged
}

protocol SubmitRaidDelegate: class {
    func update(of type: UpdateType)
}

class SubmitRaidViewModel {
    
    weak var delegate: SubmitRaidDelegate?
    var arena: Arena
    var firebaseConnector: FirebaseConnector
    var raidAlreadyRunning = false
    var showMeetupTimePicker = true
    var currentRaidLevel = 3
    var selectedRaidBoss = ""
    var selectedHatchTime: String?
    var selectedMeetupTime = "00:00"
    var selectedTimeLeft = "45 min"
    var currentRaidBosses = [String]()
    var imageName: String {
        get {
            return "level_\(currentRaidLevel)"
        }
    }
    
    init(arena: Arena, firebaseConnector: FirebaseConnector) {
        self.arena = arena
        self.firebaseConnector = firebaseConnector
        updateCurrentRaidBosses()
    }
    
    func raidAlreadyRunning(_ isRunning: Bool) {
        raidAlreadyRunning = !isRunning
        delegate?.update(of: .raidAlreadyRunning)
    }
    
    func userParticipates(_ userParticipates: Bool) {
        showMeetupTimePicker = userParticipates
        delegate?.update(of: .userParticipates)
    }
    
    func sliderChanged(to value: Int) {
        currentRaidLevel = value
        updateCurrentRaidBosses()
        delegate?.update(of: .raidLevelChanged)
    }
    
    func raidBosses() -> [String]  {
        return currentRaidBosses
    }
    
    func updateCurrentRaidBosses() {
        firebaseConnector.loadRaidBosses(for: currentRaidLevel, completion: { raidBosses in
            self.currentRaidBosses = raidBosses ?? [String]()
            self.delegate?.update(of: .currentRaidbossesChanged)
        })
    }
    
    func submitRaid() {
        let raidMeetup = RaidMeetup(meetupTime: selectedMeetupTime,
                                    participants: [firebaseConnector.user])
        let raid = Raid(level: currentRaidLevel,
                        hatchTime: selectedHatchTime,
                        raidBoss: selectedRaidBoss,
                        timeLeft: selectedTimeLeft,
                        raidMeetup: raidMeetup)
        arena.raid = raid
        firebaseConnector.saveRaid(arena: arena)
    }
}
