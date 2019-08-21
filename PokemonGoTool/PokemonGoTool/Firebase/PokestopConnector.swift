
import Firebase

class PokestopConnector {
    
    typealias Geohash = String
    typealias Pokestops = [String: Pokestop]
    
    private let pokestopsRef = Database.database().reference(withPath: DatabaseKeys.pokestops)
    private var pokestopsInGeohash: [Geohash: Pokestops] = [:]
    
    var didAddPokestopCallback: ((Pokestop) -> Void)?
    var didUpdatePokestopCallback: ((Pokestop) -> Void)?
    
    func loadPokestops(for geohash: Geohash) {
        
        guard AppSettings.showPokestops else { return }
        guard geohash != "" else { return }
        let geohashNotLoaded = pokestopsInGeohash[geohash] == nil
        guard geohashNotLoaded else { return }
        pokestopsInGeohash[geohash] = [:]
        
        pokestopsRef
            .child(geohash)
            .observeSingleEvent(of: .value, with: { snapshot in
                if let result = snapshot.children.allObjects as? [DataSnapshot] {
                    
                    var pokestops: Pokestops = [:]
                    
                    for child in result {
                        guard let pokestop: Pokestop = decode(from: child) else { continue }
                        pokestops[pokestop.id] = pokestop
                        
                        if AppSettings.isIncidentFilterActive && AppSettings.isQuestFilterActive {
                            if pokestop.incident?.isActive ?? false || pokestop.quest?.isActive ?? false {
                                self.didAddPokestopCallback?(pokestop)
                            }
                        } else if AppSettings.isIncidentFilterActive {
                            if pokestop.incident?.isActive ?? false {
                                self.didAddPokestopCallback?(pokestop)
                            }
                        } else if AppSettings.isQuestFilterActive {
                            if pokestop.quest?.isActive ?? false {
                                self.didAddPokestopCallback?(pokestop)
                            }
                        } else {
                            self.didAddPokestopCallback?(pokestop)
                        }
                    }
                    self.pokestopsInGeohash[geohash] = pokestops
                }
            })
        
        pokestopsRef
            .child(geohash)
            .observe(.childChanged, with: { snapshot in
                guard let pokestop: Pokestop = decode(from: snapshot) else { return }
                self.pokestopsInGeohash[geohash]?[pokestop.id] = pokestop
                if AppSettings.showPokestops {
                    
                    if AppSettings.isIncidentFilterActive && AppSettings.isQuestFilterActive {
                        if pokestop.incident?.isActive ?? false || pokestop.quest?.isActive ?? false {
                            self.didUpdatePokestopCallback?(pokestop)
                        }
                    } else if AppSettings.isIncidentFilterActive {
                        if pokestop.incident?.isActive ?? false {
                            self.didUpdatePokestopCallback?(pokestop)
                        }
                    } else if AppSettings.isQuestFilterActive {
                        if pokestop.quest?.isActive ?? false {
                            self.didUpdatePokestopCallback?(pokestop)
                        }
                    } else {
                        self.didUpdatePokestopCallback?(pokestop)
                    }
                }
            })
    }
    
    func clear() {
        pokestopsInGeohash.removeAll()
    }
}
