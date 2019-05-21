
import Foundation

class RaidbossManager {
    
    static let shared = RaidbossManager()
    
    var raidbosses: [RaidbossDefinition]?
    
    private init() {}
    
    func raidboss(for id: String?) -> RaidbossDefinition? {
        return raidbosses?.filter{$0.id == id}.first
    }
}
