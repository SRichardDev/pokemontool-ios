
import UIKit

enum MedalType {
    case none
    case bronze
    case silver
    case gold
    case platinum
}

struct Medal {
    
    var count: Int
    var description: String
    
    var medalType: MedalType {
        get {
            if 0 ... 9 ~= count {
                return .none
            } else if 10 ... 49 ~= count {
                return .bronze
            } else if 50 ... 99 ~= count {
                return .silver
            } else if 100 ... 999 ~= count {
                return .gold
            } else {
                return .platinum
            }
        }
    }
    
    var image: UIImage {
        get {
            switch medalType {
            case .none:
                return UIImage(named: "medal-none")!
            case .bronze:
                return UIImage(named: "medal-bronze")!
            case .silver:
                return UIImage(named: "medal-silver")!
            case .gold:
                return UIImage(named: "medal-gold")!
            case .platinum:
                return UIImage(named: "medal-platinum")!
            }
        }
    }
}

class AccountMedalViewModel {
    
    private let firebaseConnector: FirebaseConnector

    var medals: [Medal] {
        get {
            return [Medal(count: submittedPokestopsCount, description: "Eingereichte Pokéstops"),
                    Medal(count: submittedAreansCount, description: "Eingereichte Arenen"),
                    Medal(count: 10, description: "Eingereichte Raids"),
                    Medal(count: 50, description: "Eingereichte Feldforschungen"),
                    Medal(count: 100, description: "Test"),
                    Medal(count: 1000, description: "Test")]
        }
    }
    
    private var submittedPokestopsCount: Int {
        get {
            return firebaseConnector.user?.submittedPokestops?.count ?? 0
        }
    }
    
    private var submittedAreansCount: Int {
        get {
            return firebaseConnector.user?.submittedArenas?.count ?? 0
        }
    }
    
    init(firebaseConnector: FirebaseConnector) {
        self.firebaseConnector = firebaseConnector
    }
}
