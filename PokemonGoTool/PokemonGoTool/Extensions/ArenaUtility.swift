
import Foundation

class ArenaUtility {
    
    class func detailAnnotationString(for arena: Arena) -> String {
        
        if let raid = arena.raid, raid.isActive {
            let levelStars = String(repeating: "⭐️", count: raid.level)
            let hatchTime = raid.hatchTime ?? "--:--"
            let endTime = raid.endTime ?? "--:--"
            let particpantsCount = raid.meetup?.participants?.count ?? 0
            
            let formattedString = """
            \(levelStars)
            \(hatchTime) - \(endTime)
            """
            return formattedString
        }
        return arena.isEX ? "EX Arena" : "Arena"
    }
}
