
import Foundation

enum UpdateType {
    case raidLevelChanged
    case raidAlreadyRunning
    case userParticipates
}

protocol SubmitRaidDelegate: class {
    func update(of type: UpdateType)
}

class SubmitRaidViewModel {
    
    weak var delegate: SubmitRaidDelegate?
    var firebaseConnector: FirebaseConnector
    var showHatchTimePicker = true
    var showMeetupTimePicker = true
    var currentRaidLevel = 3
    var selectedHatchTime = "00:00"
    var selectedMeetupTime = "00:00"
    var selectedTimeLeft = "45 min"
    var imageName: String {
        get {
            return "level_\(currentRaidLevel)"
        }
    }
    
    init(firebaseConnector: FirebaseConnector) {
        self.firebaseConnector = firebaseConnector
    }
    
    func raidAlreadyRunning(_ isRunning: Bool) {
        showHatchTimePicker = !isRunning
        delegate?.update(of: .raidAlreadyRunning)
    }
    
    func userParticipates(_ userParticipates: Bool) {
        showMeetupTimePicker = userParticipates
        delegate?.update(of: .userParticipates)
    }
    
    func sliderChanged(to value: Int) {
        currentRaidLevel = value
        delegate?.update(of: .raidLevelChanged)
    }
    
    func submitRaid() {
//        let raid = Raid(level: currentRaidLevel, hatchTime: selectedHatchTime)
    }
}
