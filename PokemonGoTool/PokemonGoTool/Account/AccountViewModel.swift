
import UIKit

class AccountViewModel {
    
    private let firebaseConnector: FirebaseConnector
    
    var accountMedalViewModel: AccountMedalViewModel {
        get {
            return AccountMedalViewModel(firebaseConnector: firebaseConnector)
        }
    }
    
    var trainerName: String {
        get {
            return firebaseConnector.user?.publicData?.trainerName ?? ""
        }
    }
    
    var currentTeam: Team? {
        get {
            return firebaseConnector.user?.publicData?.team
        }
    }
    
    var currentLevel: Int {
        get {
            return (firebaseConnector.user?.publicData?.level ?? 0)
        }
    }
    
    var trainerCode: String {
        get {
            return firebaseConnector.user?.publicData?.trainerCode ?? ""
        }
    }
    
    var isLoggedIn: Bool {
        get {
            return firebaseConnector.isSignedIn
        }
    }
    
    init(firebaseConnector: FirebaseConnector) {
        self.firebaseConnector = firebaseConnector
    }
    
    func updateTrainerName(_ name: String) {
        guard name != "" else { return }
        firebaseConnector.user?.updateTrainerName(name)
    }
    
    func updateTeam(_ team: Team) {
        firebaseConnector.user?.updateTeam(team)
    }
    
    func updateLevel(_ level: Int) {
        firebaseConnector.user?.updateTrainerLevel(level)
    }
    
    func updateTrainerCode(_ code: String) {
        guard code != "" else { return }
        firebaseConnector.user?.updateTrainerCode(code)
    }
}
