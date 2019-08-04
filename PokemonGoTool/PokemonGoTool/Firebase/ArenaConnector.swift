
import Firebase

class ArenaConnector {

    typealias Geohash = String
    typealias Arenas = [String: Arena]

    private let arenasRef = Database.database().reference(withPath: DatabaseKeys.arenas)
    private var arenasInGeohash: [Geohash: Arenas] = [:]

    var didAddArenaCallback: ((Arena) -> Void)?
    var didUpdateArenaCallback: ((Arena) -> Void)?
    
    func loadArenas(for geohash: Geohash) {
        
        guard geohash != "" else { return }
        let geohashNotLoaded = arenasInGeohash[geohash] == nil
        guard geohashNotLoaded else { return }
        arenasInGeohash[geohash] = [:]

        arenasRef
            .child(geohash)
            .observeSingleEvent(of: .value, with: { snapshot in
                if let result = snapshot.children.allObjects as? [DataSnapshot] {
                    
                    var arenas: Arenas = [:]
                    
                    for child in result {
                        guard let arena: Arena = decode(from: child) else { continue }
                        arenas[arena.id] = arena
                        self.didAddArenaCallback?(arena)
                    }
                    self.arenasInGeohash[geohash] = arenas
                }
            })
        
        arenasRef
            .child(geohash)
            .observe(.childChanged, with: { snapshot in
                guard let arena: Arena = decode(from: snapshot) else { return }
                self.arenasInGeohash[geohash]?[arena.id] = arena
                self.didUpdateArenaCallback?(arena)
            })
    }
}
