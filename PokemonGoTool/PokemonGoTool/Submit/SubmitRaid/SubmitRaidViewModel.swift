
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
    
    var showHatchTimePicker = true
    var showMeetupTimePicker = true
    var currentRaidLevel = 3
    var selectedTime = "00:00"
    var imageName: String {
        get {
            return "level_\(currentRaidLevel)"
        }
    }
    
    init() {
        
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
}
