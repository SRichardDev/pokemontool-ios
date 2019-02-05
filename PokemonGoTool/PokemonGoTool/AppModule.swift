
import Foundation
import UIKit

class AppModule {
    
    var firebaseConnector: FirebaseConnector!
    var locationManager = LocationManager()
    var pushManager = PushManager()
    
    init() {
        firebaseConnector = FirebaseConnector()
    }
}
