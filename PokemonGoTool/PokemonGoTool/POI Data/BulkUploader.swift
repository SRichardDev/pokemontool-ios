
import Foundation

class BulkUploader {
    
    let firebaseConnector: FirebaseConnector
    private var timer: Timer?
    private var counter = 1
    
    init(firebaseConnector: FirebaseConnector) {
        self.firebaseConnector = firebaseConnector
        
        
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: { (timer) in
            self.uploadPOIs(for: "data-\(self.counter)")
            self.counter += 1
            
            if self.counter == 39 {
                timer.invalidate()
                print("DONE")
            }
        })
    }
    
    func uploadPOIs(for filename: String) {
        guard let filepath = Bundle.main.path(forResource: filename, ofType: "json") else { return }
        let data = try! Data(contentsOf: URL(fileURLWithPath: filepath))
        let jsonDecoder = JSONDecoder()
        let responseModel = try! jsonDecoder.decode([Json4Swift_Base].self, from: data)
        
        let serialQueue = DispatchQueue(label: "foo")
        
        for poi in responseModel {
            serialQueue.async {
                if poi.gym {
                    let arena = Arena(name: poi.name,
                                      latitude: poi.loc.coordinates[1],
                                      longitude: poi.loc.coordinates[0],
                                      submitter: "System",
                                      isExArena: false)
                    self.firebaseConnector.saveArena(arena)
                    print("Gym Uploaded: \(poi.name)")
                } else if poi.stop {
                    
                    let pokestop = Pokestop(name: poi.name,
                                            latitude: poi.loc.coordinates[1],
                                            longitude: poi.loc.coordinates[0],
                                            submitter: "System")
                    self.firebaseConnector.savePokestop(pokestop)
                    print("Stop Uploaded: \(poi.name)")
                }
            }
        }
        print("✅ Done: \(filename)")
    }
}
