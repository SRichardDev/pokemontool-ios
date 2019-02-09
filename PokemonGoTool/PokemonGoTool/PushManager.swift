
import Foundation
import UserNotifications
import MapKit

protocol PushManagerDelegate: class {
    func didReceivePushNotification(with title: String, message: String, coordinate: CLLocationCoordinate2D)
}

class PushManager {
    
    weak var delegate: PushManagerDelegate?

    func parsePushNotification(response: UNNotificationResponse) {
        let title = response.notification.request.content.title
        let message = response.notification.request.content.body
        let userInfo = response.notification.request.content.userInfo
        guard let latitude = userInfo["latitude"] as? String else {return}
        guard let longitude = userInfo["longitude"] as? String else {return}
        
        let coordiante = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude.double),
                                                longitude:CLLocationDegrees(longitude.double))

        delegate?.didReceivePushNotification(with: title, message: message, coordinate: coordiante)
    }
}
