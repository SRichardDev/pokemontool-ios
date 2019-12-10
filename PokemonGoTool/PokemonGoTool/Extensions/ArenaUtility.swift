
import Foundation

class ArenaUtility {
    
    class func detailAnnotationString(for arena: Arena) -> String {
        
        if let raid = arena.raid, raid.isActive,
            let hatchDate = raid.hatchDate,
            let endDate = raid.endDate {
            let levelStars = String(repeating: "⭐️", count: raid.level)
            let hatchTime = DateUtility.timeString(for: hatchDate)
            let endTime = DateUtility.timeString(for: endDate)
            let particpantsCount = raid.meetup?.participants?.count ?? 0
            
            let formattedString = """
            \(levelStars)
            \(hatchTime) - \(endTime)
            Teilnehmer: \(particpantsCount)
            """
            return formattedString
        }
        return arena.isEX ? "EX Arena" : "Arena"
    }
}
