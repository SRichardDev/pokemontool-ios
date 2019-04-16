
import UIKit

class AccountViewModel {
    
    private let firebaseConnector: FirebaseConnector
    
    var trainerName: String {
        get {
            return firebaseConnector.user?.trainerName ?? "Kein Trainer Name gesetzt"
        }
    }
    
    var currentTeam: Team? {
        get {
            return firebaseConnector.user?.team
        }
    }
    
    var currentLevel: Int {
        get {
            return (firebaseConnector.user?.level ?? 0)
        }
    }
    
    var isLoggedIn: Bool {
        get {
            return firebaseConnector.isSignedIn
        }
    }
    
    var submittedPokestopsCount: Int {
        get {
            return firebaseConnector.user?.submittedPokestops?.count ?? 0
        }
    }
    
    var submittedAreansCount: Int {
        get {
            return firebaseConnector.user?.submittedArenas?.count ?? 0
        }
    }
    
    init(firebaseConnector: FirebaseConnector) {
        self.firebaseConnector = firebaseConnector
    }
    
    func updateTeam(_ team: Team) {
        firebaseConnector.user?.updateTeam(team)
    }
    
    func updateLevel(_ level: Int) {
        firebaseConnector.user?.updateTrainerLevel(level)
    }
}
