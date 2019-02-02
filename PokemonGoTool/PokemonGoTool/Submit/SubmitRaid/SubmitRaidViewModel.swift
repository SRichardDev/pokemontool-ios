
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
    var firebaseConnector: FirebaseConnector
    var raidAlreadyRunning = false
    var showMeetupTimePicker = true
    var currentRaidLevel = 3
    var selectedHatchTime = "00:00"
    var selectedMeetupTime = "00:00"
    var selectedTimeLeft = "45 min"
    var currentRaidBosses = [String]()
    var imageName: String {
        get {
            return "level_\(currentRaidLevel)"
        }
    }
    
    init(firebaseConnector: FirebaseConnector) {
        self.firebaseConnector = firebaseConnector
        updateRaidCurrentBosses()
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
        updateRaidCurrentBosses()
        delegate?.update(of: .raidLevelChanged)
    }
    
    func raidBosses() -> [String]  {
        return currentRaidBosses
    }
    
    func updateRaidCurrentBosses() {
        firebaseConnector.loadRaidBosses(for: currentRaidLevel, completion: { raidBosses in
            self.currentRaidBosses = raidBosses ?? [String]()
            self.delegate?.update(of: .currentRaidbossesChanged)
        })
    }
    
    func submitRaid() {
//        let raid = Raid(level: currentRaidLevel, hatchTime: selectedHatchTime)
    }
}
