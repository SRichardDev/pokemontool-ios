
import Foundation
import UIKit

protocol AppModuleAccessible {
    var firebaseConnector: FirebaseConnector! { get set }
    var locationManager: LocationManager! { get set }
}

class AppModule {
    
    var firebaseConnector: FirebaseConnector!
    var locationManager = LocationManager()
    let tabBarController: UITabBarController!
    
    init() {
        firebaseConnector = FirebaseConnector()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        tabBarController = storyboard.instantiateInitialViewController() as? UITabBarController
        
        tabBarController.viewControllers?.forEach { viewController in
            if var appModuleAccessibleViewController = viewController as? AppModuleAccessible {
                appModuleAccessibleViewController.firebaseConnector = firebaseConnector
                appModuleAccessibleViewController.locationManager = locationManager
            }
        }
    }
}
