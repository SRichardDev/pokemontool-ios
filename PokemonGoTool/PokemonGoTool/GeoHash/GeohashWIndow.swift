
import MapKit

class GeohashWindow {
    
    var currentGeohash = ""
    var geohashMatrix = [[GeohashBox]]()
    let defaultLengthTopToBottom = 40
    
    init(topLeftCoordinate: CLLocationCoordinate2D,
         topRightCoordiante: CLLocationCoordinate2D,
         bottomLeftCoordinated: CLLocationCoordinate2D,
         bottomRightCoordiante: CLLocationCoordinate2D) {
        
        let topLeftGeohash = Geohash.encode(latitude: topLeftCoordinate.latitude, longitude: topLeftCoordinate.longitude)
        let topRightGeohash = Geohash.encode(latitude: topRightCoordiante.latitude, longitude: topRightCoordiante.longitude)
        let bottomLeftGeohash = Geohash.encode(latitude: bottomLeftCoordinated.latitude, longitude: bottomLeftCoordinated.longitude)
        
        let lengthLeftToRight = length(for: topLeftGeohash, to: topRightGeohash, direction: .east)
        let lengthTopToBottom = length(for: topLeftGeohash, to: bottomLeftGeohash, direction: .south)
        
        if lengthTopToBottom > defaultLengthTopToBottom {
            return
        }
        
        let topToBottomGeohashBoxes = neighborsLineTopToBottom(from: topLeftGeohash, length: lengthTopToBottom)
        
        for lineStartGeohash in topToBottomGeohashBoxes {
            let neighborsLine = neighborsLineLeftToRight(from: lineStartGeohash.hash, length: lengthLeftToRight)
            geohashMatrix.append(neighborsLine)
        }
    }
    
    private func neighborsLineLeftToRight(from leftGeohash: String, length: Int) -> [GeohashBox] {
        return geohashLine(from: leftGeohash, length: length, direction: .east)
    }
    
    private func neighborsLineTopToBottom(from topGeohash: String, length: Int) -> [GeohashBox] {
        return geohashLine(from: topGeohash, length: length, direction: .south)
    }
    
    private func geohashLine(from: String, length: Int, direction: CompassPoint) -> [GeohashBox] {
        let startGeohashBox = Geohash.geohashbox(from)
        
        var reachedEnd = false
        var geohashBoxes = [GeohashBox]()
        geohashBoxes.reserveCapacity(length)
        var currentGeohashBox = startGeohashBox
        
        while !reachedEnd {
            reachedEnd = length == geohashBoxes.count
            guard let unwrappedCurrentGeohashBox = currentGeohashBox else { continue }
            geohashBoxes.append(unwrappedCurrentGeohashBox)
            currentGeohashBox = Geohash.neighbor(unwrappedCurrentGeohashBox, direction: direction, precision: 6)
        }
        return geohashBoxes
    }
    
    private func length(for startGeohash: String, to endGeohash: String, direction: CompassPoint) -> Int {
        let startGeohashBox = Geohash.geohashbox(startGeohash)
        let endGeohashBox = Geohash.geohashbox(endGeohash)

        var reachedEnd = false
        var currentGeohashBox = startGeohashBox
        var count = 0
        
        while !reachedEnd {
            reachedEnd = currentGeohashBox == endGeohashBox
            guard let unwrappedCurrentGeohashBox = currentGeohashBox else { continue }
            count += 1
            currentGeohashBox = Geohash.neighbor(unwrappedCurrentGeohashBox, direction: direction, precision: 6)
        }
        return count
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
