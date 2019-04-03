
import UIKit

class AccountViewModel {
    
    private let firebaseConnector: FirebaseConnector
    
    var currentTeam: Int {
        get {
            return firebaseConnector.user?.team?.rawValue ?? 0
        }
    }
    
    var teamColor: UIColor? {
        get {
            return firebaseConnector.user?.teamColor
        }
    }
    
    var currentLevel: Int {
        get {
            return 40 - (firebaseConnector.user?.level ?? 0)
        }
    }
    
    init(firebaseConnector: FirebaseConnector) {
        self.firebaseConnector = firebaseConnector
    }
    
    func updateTeam(_ team: Team) -> UIColor? {
        firebaseConnector.user?.updateTeam(team)
        return firebaseConnector.user?.teamColor
    }
    
    func updateLevel(_ level: Int) {
        firebaseConnector.user?.updateTrainerLevel(level)
    }
}
