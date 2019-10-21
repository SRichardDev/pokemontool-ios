
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
    var timeLeft = 45
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
                
        var meetup = RaidMeetup(meetupDate: meetupDate)

        if isUserParticipating {
            meetup.participants = [userId: ""]
        }
        
        if isRaidAlreadyRunning {
            let time = TimeInterval(-((45 - timeLeft) * 60))
            hatchDate = Date().addingTimeInterval(time)
        }
        
        let raid = Raid(level: selectedRaidLevel,
                        hatchDate: hatchDate,
                        endDate: endDate,
                        submitter: userId,
                        meetup: meetup)
        arena.raid = raid
        firebaseConnector.saveRaid(arena: arena)
        delegate?.update(of: .raidSubmitted)
    }
    
    func meetupTimeDidChange() {
        //not needed here
    }
}
