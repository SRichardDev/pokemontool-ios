
import MapKit

class GeohashWindow {
    
    var currentGeohash = ""
    
    var neighborGeohashes: [String]? {
        get {
            guard let neighbors = Geohash.neighbors(currentGeohash) else { return [""] }
            
            var neighborGeohashesForDepth = [String]()
            
            for neighbor in neighbors {
                guard let neighborsOfNeighbor = Geohash.neighbors(neighbor) else { return [""] }
                neighborGeohashesForDepth = neighborGeohashesForDepth + neighborsOfNeighbor
                neighborGeohashesForDepth.removeDuplicates()
            }
            return neighborGeohashesForDepth
        }
    }
    
    func neighborGeohashes(for geohash: String) -> [String] {
        guard let neighbors = Geohash.neighbors(geohash) else { return [""] }
        
        var neighborGeohashesForDepth = [String]()
        
        for neighbor in neighbors {
            guard let neighborsOfNeighbor = Geohash.neighbors(neighbor) else { return [""] }
            neighborGeohashesForDepth = neighborGeohashesForDepth + neighborsOfNeighbor
            neighborGeohashesForDepth.removeDuplicates()
        }
        return neighborGeohashesForDepth
    }
}



extension Array where Element: Equatable {
    mutating func removeDuplicates() {
        var result = [Element]()
        for value in self {
            if !result.contains(value) {
                result.append(value)
            }
        }
        self = result
    }
}
