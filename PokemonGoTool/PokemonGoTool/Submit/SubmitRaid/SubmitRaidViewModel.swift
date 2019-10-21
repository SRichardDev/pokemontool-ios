
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
    var meetupDate: Date? { get set }
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
    var selectedTimeLeft = "45"
    var meetupTimeSelectionType: MeetupTimeSelectionType = .initial
    var hatchDate: Date?
    var meetupDate: Date?
    var endDate: Date? {
        return hatchDate?.addingTimeInterval(45 * 60)
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
        
//        deleteOldRaidMeetupIfNeeded()
        
        var meetup: RaidMeetup

        if isUserParticipating {
            guard let meetupDate = meetupDate else { fatalError() }
            meetup = RaidMeetup(meetupDate: meetupDate)
        } else {
            meetup = RaidMeetup(meetupDate: nil)
        }
        

        if isUserParticipating {
            meetup.participants = [userId: ""]
        }
        
        let raid = Raid(level: selectedRaidLevel,
                        hatchDate: hatchDate,
                        endDate: endDate,
                        submitter: userId,
                        meetup: meetup)
        arena.raid = raid
    
//        if isRaidAlreadyRunning {
//            let meetupId = firebaseConnector.saveRaidMeetup(raidMeetup: meetup)
//            let raid = Raid(level: selectedRaidLevel,
//                            raidBoss: selectedRaidBoss?.id,
//                            endTime: endTime,
//                            submitter: userId)
//            arena.raid = raid
//
//            if isUserParticipating {
//                firebaseConnector.userParticipates(in: raid, for: &arena)
//            }
//
//        } else {
//            let meetupId = firebaseConnector.saveRaidMeetup(raidMeetup: meetup)
//            let raid = Raid(level: selectedRaidLevel,
//                            hatchTime: selectedHatchTime,
//                            endTime: endTime,
//                            submitter: userId)
//            arena.raid = raid
//
//            if isUserParticipating {
//                firebaseConnector.userParticipates(in: raid, for: &arena)
//            }
//        }
        firebaseConnector.saveRaid(arena: arena)
        delegate?.update(of: .raidSubmitted)
    }
    
    private func deleteOldRaidMeetupIfNeeded() {
//        if let oldRaidMeetupId = arena.raid?.raidMeetupId {
//            firebaseConnector.deleteOldRaidMeetup(for: oldRaidMeetupId)
//        }
    }
    
    func meetupTimeDidChange() {
        //not needed here
    }
}
