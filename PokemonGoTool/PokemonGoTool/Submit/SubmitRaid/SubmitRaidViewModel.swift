
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

protocol MeetupTimeSelectable {
    var selectedMeetupTime: String { get set }
}

class SubmitRaidViewModel: MeetupTimeSelectable {
    
    weak var delegate: SubmitRaidDelegate?
    var arena: Arena
    var firebaseConnector: FirebaseConnector
    var isRaidAlreadyRunning = false
    var isUserParticipating = false
    var selectedRaidLevel = 3
    var selectedRaidBoss: RaidbossDefinition?
    var selectedHatchTime = "00:00"
    var selectedMeetupTime = "00:00"
    var selectedTimeLeft = "45"
    var endTime: String {
        get {
            guard let hatchDate = DateUtility.date(for: selectedHatchTime) else { return "00:00" }
            return DateUtility.timeStringWithAddedMinutesToDate(minutes: Int(selectedTimeLeft.double), date: hatchDate)
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
    
    func updateCurrentRaidBosses() {
        self.delegate?.update(of: .currentRaidbossesChanged)
    }
    
    func submitRaid() {
        deleteOldRaidMeetupIfNeeded()
        let raidMeetup = RaidMeetup(meetupTime: selectedMeetupTime)
    
        if isRaidAlreadyRunning {
            if isUserParticipating {
                
                let id = firebaseConnector.saveRaidMeetup(raidMeetup: raidMeetup)

                let raid = Raid(level: selectedRaidLevel,
                                raidBoss: selectedRaidBoss?.id,
                                endTime: endTime,
                                raidMeetupId: id)
                arena.raid = raid
                firebaseConnector.userParticipates(in: raid, for: &arena)
            } else {
                let raid = Raid(level: selectedRaidLevel,
                                raidBoss: selectedRaidBoss?.id,
                                endTime: endTime)
                arena.raid = raid
            }
        } else {
            if isUserParticipating {
                let id = firebaseConnector.saveRaidMeetup(raidMeetup: raidMeetup)
                let raid = Raid(level: selectedRaidLevel,
                                hatchTime: selectedHatchTime,
                                endTime: endTime,
                                raidMeetupId: id)
                arena.raid = raid
                firebaseConnector.userParticipates(in: raid, for: &arena)

            } else {
                let raid = Raid(level: selectedRaidLevel,
                                hatchTime: selectedHatchTime,
                                endTime: endTime)
                arena.raid = raid
            }
        }
        firebaseConnector.saveRaid(arena: arena)
    }
    
    private func deleteOldRaidMeetupIfNeeded() {
        if let oldRaidMeetupId = arena.raid?.raidMeetupId {
            firebaseConnector.deleteOldRaidMeetup(for: oldRaidMeetupId)
        }
    }
}
