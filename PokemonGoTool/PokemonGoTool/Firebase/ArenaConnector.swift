
import Firebase

class ArenaConnector {

    typealias Geohash = String
    typealias Arenas = [String: Arena]

    private let arenasRef = Database.database().reference(withPath: DatabaseKeys.arenas)
    private var arenasInGeohash: [Geohash: Arenas] = [:]

    var didAddArenaCallback: ((Arena) -> Void)?
    var didUpdateArenaCallback: ((Arena) -> Void)?
    private var activeLevelFilter: [Int: Bool]? {
        if let levelFilter = UserDefaults.standard.object(forKey: "levelFilter") as? Data {
            return try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(levelFilter) as! [Int: Bool]
        }
        return nil
    }
    
    func loadArenas(for geohash: Geohash) {
        
        guard AppSettings.showArenas else { return }

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
                        
                        let anyLevelFilterActive = (self.activeLevelFilter?.values.reduce(false) { $0 || $1 }) ?? false
                        
                        if anyLevelFilterActive {
                            if let raid = arena.raid {
                                if raid.isActive {
                                    if self.activeLevelFilter?[raid.level] ?? false {
                                        self.didAddArenaCallback?(arena)
                                    }
                                }
                            }
                        } else {
                            self.didAddArenaCallback?(arena)
                        }
                        
                    }
                    self.arenasInGeohash[geohash] = arenas
                }
            })
        
        arenasRef
            .child(geohash)
            .observe(.childChanged, with: { snapshot in
                guard let arena: Arena = decode(from: snapshot) else { return }
                self.arenasInGeohash[geohash]?[arena.id] = arena
                
                let anyLevelFilterActive = (self.activeLevelFilter?.values.reduce(false) { $0 || $1 }) ?? false
                
                if AppSettings.showArenas {
                    if anyLevelFilterActive {
                        if let raid = arena.raid {
                            if raid.isActive {
                                if self.activeLevelFilter?[raid.level] ?? false {
                                    self.didUpdateArenaCallback?(arena)
                                }
                            }
                        }
                    } else {
                        self.didUpdateArenaCallback?(arena)
                    }
                }
            })
    }
    
    func clear() {
        arenasInGeohash.removeAll()
    }
}
