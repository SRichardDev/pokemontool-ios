
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
    var isRaidAlreadyRunning = false
    var isUserParticipating = false
    var selectedRaidLevel = 3
    var selectedRaidBoss: RaidbossDefinition?
    var selectedHatchTime: String?
    var selectedMeetupTime = "00:00"
    var selectedTimeLeft: String?
    var currentRaidBosses: [RaidbossDefinition] {
        get {
            return firebaseConnector.raidbosses.filter { Int($0.level) == selectedRaidLevel }
        }
    }
    var imageName: String {
        get {
            return "level_\(selectedRaidLevel)"
        }
    }
    
    init(arena: Arena, firebaseConnector: FirebaseConnector) {
        self.arena = arena
        self.firebaseConnector = firebaseConnector
        updateCurrentRaidBosses()
    }
    
    func raidAlreadyRunning(_ isRunning: Bool) {
        isRaidAlreadyRunning = isRunning
        delegate?.update(of: .raidAlreadyRunning)
    }
    
    func userParticipates(_ userParticipates: Bool) {
        isUserParticipating = userParticipates
        delegate?.update(of: .userParticipates)
    }
    
    func raidLevelChanged(to value: Int) {
        selectedRaidLevel = value
        updateCurrentRaidBosses()
        delegate?.update(of: .raidLevelChanged)
    }
    
    func raidBosses() -> [RaidbossDefinition]  {
        return currentRaidBosses
    }
    
    func updateCurrentRaidBosses() {
        self.delegate?.update(of: .currentRaidbossesChanged)
    }
    
    func submitRaid() {
        guard let user = firebaseConnector.user else { fatalError("Handle error")}
        let raidMeetup = RaidMeetup(meetupTime: selectedMeetupTime,
                                    participants: [user])
    
        var raid: Raid?
        if isRaidAlreadyRunning {
            guard let selectedTimeLeft = selectedTimeLeft else { return }

            if isUserParticipating {
                
                let id = firebaseConnector.saveRaidMeetup(raidMeetup: raidMeetup)
                
                raid = Raid(level: selectedRaidLevel,
                            raidBoss: selectedRaidBoss,
                            timeLeft: selectedTimeLeft,
                            raidMeetupId: id)
            } else {
                raid = Raid(level: selectedRaidLevel,
                            raidBoss: selectedRaidBoss,
                            timeLeft: selectedTimeLeft)
            }
        } else {
            guard let selectedHatchTime = selectedHatchTime else { return }

            if isUserParticipating {
                let id = firebaseConnector.saveRaidMeetup(raidMeetup: raidMeetup)

                raid = Raid(level: selectedRaidLevel,
                            hatchTime: selectedHatchTime,
                            raidBoss: selectedRaidBoss,
                            raidMeetupId: id)

            } else {
                raid = Raid(level: selectedRaidLevel,
                            hatchTime: selectedHatchTime,
                            raidBoss: selectedRaidBoss)
            }
        }
        arena.raid = raid
        firebaseConnector.saveRaid(arena: arena)
    }
}
