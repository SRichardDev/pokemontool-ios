
import Foundation

enum SubmitRaidUpdateType {
    case raidLevelChanged
    case raidAlreadyRunning
    case userParticipates
    case currentRaidbossesChanged
}

protocol SubmitRaidDelegate: class {
    func update(of type: SubmitRaidUpdateType)
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
    var selectedTimeLeft = "45"
    var currentRaidBosses: [RaidbossDefinition] {
        get {
            return RaidbossManager.shared.raidbosses?.filter { Int($0.level) == selectedRaidLevel } ?? []
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
        let raidMeetup = RaidMeetup(meetupTime: selectedMeetupTime)
    
        if isRaidAlreadyRunning {
            if isUserParticipating {
                
                let id = firebaseConnector.saveRaidMeetup(raidMeetup: raidMeetup)

                let raid = Raid(level: selectedRaidLevel,
                                raidBoss: selectedRaidBoss?.id,
                                timeLeft: selectedTimeLeft,
                                raidMeetupId: id)
                arena.raid = raid
                firebaseConnector.userParticipates(in: raid, for: &arena)
            } else {
                let raid = Raid(level: selectedRaidLevel,
                                raidBoss: selectedRaidBoss?.id,
                                timeLeft: selectedTimeLeft)
                arena.raid = raid
            }
        } else {
            guard let selectedHatchTime = selectedHatchTime else { return }

            if isUserParticipating {
                let id = firebaseConnector.saveRaidMeetup(raidMeetup: raidMeetup)
                let raid = Raid(level: selectedRaidLevel,
                                hatchTime: selectedHatchTime,
                                raidMeetupId: id)
                arena.raid = raid
                firebaseConnector.userParticipates(in: raid, for: &arena)

            } else {
                let raid = Raid(level: selectedRaidLevel,
                                hatchTime: selectedHatchTime)
                arena.raid = raid
            }
        }
        firebaseConnector.saveRaid(arena: arena)
    }
}
