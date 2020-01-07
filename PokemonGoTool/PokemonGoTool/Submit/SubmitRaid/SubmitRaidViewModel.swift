
import Foundation

enum SubmitRaidUpdateType {
    case raidLevelChanged
    case raidAlreadyRunning
    case userParticipates
    case raidbossChanged
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

protocol RaidbossSelectable {
    var selectedRaidBoss: Int? { get set }
    func updateRaidboss(dexNumber: Int)
}

class SubmitRaidViewModel: MeetupTimeSelectable, RaidbossSelectable {
    weak var delegate: SubmitRaidDelegate?
    var arena: Arena
    var firebaseConnector: FirebaseConnector
    var isRaidAlreadyRunning = false
    var isUserParticipating = false
    var selectedRaidLevel = 3
    var selectedRaidBoss: Int?
    var timeLeft = 45
    var meetupTimeSelectionType: MeetupTimeSelectionType = .initial
    var hatchDate: Date?
    var meetupDate: Date?
    
    var title: String {
        return "Neuer Level \(selectedRaidLevel) Raid"
    }
    
    var endDate: Date? {
        return hatchDate?.addingTimeInterval(45 * 60)
    }

    var imageName: String {
        return "level_\(selectedRaidLevel)"
    }
    
    init(arena: Arena, firebaseConnector: FirebaseConnector) {
        self.arena = arena
        self.firebaseConnector = firebaseConnector
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
        delegate?.update(of: .raidLevelChanged)
    }
    
    func updateRaidboss(dexNumber: Int) {
        selectedRaidBoss = dexNumber
        delegate?.update(of: .raidbossChanged)
    }
    
    func submitRaid() {
        guard let userId = firebaseConnector.user?.id else { NotificationBannerManager.shared.show(.unregisteredUser); return}
                
        var meetup = RaidMeetup(meetupDate: isUserParticipating ? meetupDate : nil )

        if isUserParticipating {
            meetup.participants = [userId: ""]
        }
        
        if isRaidAlreadyRunning {
            let time = TimeInterval(-((45 - timeLeft) * 60))
            hatchDate = Date().addingTimeInterval(time)
        }
        
        firebaseConnector.chatConnector.deleteOldChat(for: arena)
        firebaseConnector.clearRaid(for: arena)

        let raid = Raid(level: selectedRaidLevel,
                        hatchDate: hatchDate,
                        endDate: endDate,
                        submitter: userId,
                        raidboss: selectedRaidBoss,
                        meetup: meetup)
        arena.raid = raid
        firebaseConnector.saveRaid(arena: arena)
        delegate?.update(of: .raidSubmitted)
    }
    
    func meetupTimeDidChange() {
        //not needed here
    }
}
