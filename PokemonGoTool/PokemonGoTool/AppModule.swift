
import Foundation
import UIKit

class AppModule {
    
    var firebaseConnector: FirebaseConnector!
    var locationManager = LocationManager.shared
    
    init() {
        firebaseConnector = FirebaseConnector()
    }
}
