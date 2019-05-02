
import Foundation
import UserNotifications
import MapKit

struct PushNotification {
    let title: String
    let message: String
    let coordinate: CLLocationCoordinate2D
}

protocol PushManagerDelegate: class {
    func didReceivePush()
}

class PushManager {
    
    static let shared = PushManager()
    weak var delegate: PushManagerDelegate?
    var latestPushNotification: PushNotification?
    
    private init() {}
    
    func parsePushNotification(response: UNNotificationResponse) {
        let title = response.notification.request.content.title
        let message = response.notification.request.content.body
        let userInfo = response.notification.request.content.userInfo
        guard let latitude = userInfo["latitude"] as? String else {return}
        guard let longitude = userInfo["longitude"] as? String else {return}
        
        let coordiante = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude.double),
                                                longitude:CLLocationDegrees(longitude.double))

        latestPushNotification = PushNotification(title: title, message: message, coordinate: coordiante)
        delegate?.didReceivePush()
    }
}
