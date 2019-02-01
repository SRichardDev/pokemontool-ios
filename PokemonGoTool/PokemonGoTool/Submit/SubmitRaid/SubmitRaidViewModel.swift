
import Foundation

enum UpdateType {
    case raidLevelChanged
    case switchChanged
}

protocol SubmitRaidDelegate: class {
    func update(of type: UpdateType)
}

class SubmitRaidViewModel {
    
    weak var delegate: SubmitRaidDelegate?
    
    var showTimePicker = false
    var currentRaidLevel = 3
    var imageName: String {
        get {
            return "level_\(currentRaidLevel)"
        }
    }
    
    init() {
        
    }
    
    func switchToggled(enabled: Bool) {
        showTimePicker = enabled
        delegate?.update(of: .switchChanged)
    }
    
    func sliderChanged(to value: Int) {
        currentRaidLevel = value
        delegate?.update(of: .raidLevelChanged)
    }
}
