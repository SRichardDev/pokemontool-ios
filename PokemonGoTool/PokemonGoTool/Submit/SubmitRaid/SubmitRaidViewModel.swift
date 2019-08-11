
import Foundation

enum SubmitRaidUpdateType {
    case raidLevelChanged
    case raidAlreadyRunning
    case userParticipates
    case currentRaidbossesChanged
    case raidSubmitted
}

protocol SubmitRaidDelegate: class {
    func update(of type: SubmitRaidUpdateType)
}

enum MeetupTimeSelectionType {
    case initial
    case change
}

protocol MeetupTimeSelectable {
    var meetupTimeSelectionType: MeetupTimeSelectionType { get set }
    var selectedMeetupTime: String? { get set }
    func meetupTimeDidChange()
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
    var selectedMeetupTime: String?
    var selectedTimeLeft = "45"
    var meetupTimeSelectionType: MeetupTimeSelectionType = .initial
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
        guard let userId = firebaseConnector.user?.id else { NotificationBannerManager.shared.show(.unregisteredUser); return}
        
        deleteOldRaidMeetupIfNeeded()
        
        let meetup: RaidMeetup

        if isUserParticipating {
            meetup = RaidMeetup(meetupTime: selectedMeetupTime)
        } else {
            meetup = RaidMeetup(meetupTime: "--:--")
        }
        
        if isRaidAlreadyRunning {
            let meetupId = firebaseConnector.saveRaidMeetup(raidMeetup: meetup)
            let raid = Raid(level: selectedRaidLevel,
                            raidBoss: selectedRaidBoss?.id,
                            endTime: endTime,
                            submitter: userId,
                            raidMeetupId: meetupId)
            arena.raid = raid
            
            if isUserParticipating {
                firebaseConnector.userParticipates(in: raid, for: &arena)
            }
            
        } else {
            let meetupId = firebaseConnector.saveRaidMeetup(raidMeetup: meetup)
            let raid = Raid(level: selectedRaidLevel,
                            hatchTime: selectedHatchTime,
                            endTime: endTime,
                            submitter: userId,
                            raidMeetupId: meetupId)
            arena.raid = raid

            if isUserParticipating {
                firebaseConnector.userParticipates(in: raid, for: &arena)
            }
        }
        firebaseConnector.saveRaid(arena: arena)
        delegate?.update(of: .raidSubmitted)
    }
    
    private func deleteOldRaidMeetupIfNeeded() {
        if let oldRaidMeetupId = arena.raid?.raidMeetupId {
            firebaseConnector.deleteOldRaidMeetup(for: oldRaidMeetupId)
        }
    }
    
    func meetupTimeDidChange() {
        //not needed here
    }
}
