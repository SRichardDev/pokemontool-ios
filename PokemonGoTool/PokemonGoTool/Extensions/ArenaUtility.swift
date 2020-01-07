
import Foundation

class ArenaUtility {
    
    class func detailAnnotationString(for arena: Arena) -> String {
        
        if let raid = arena.raid, raid.isActive,
            let hatchDate = raid.hatchDate,
            let endDate = raid.endDate {
            let levelStars = String(repeating: "⭐️", count: raid.level)
            let hatchTime = DateUtility.timeString(for: hatchDate)
            let endTime = DateUtility.timeString(for: endDate)
            let raidboss = RaidbossManager.shared.pokemonNameFor(dexNumber: raid.raidboss)
            
            let formattedString = """
            \(levelStars)
            \(hatchTime) - \(endTime)
            Raidboss: \(raidboss)
            """
            return formattedString
        }
        return arena.isEX ? "EX Arena" : "Arena"
    }
}
