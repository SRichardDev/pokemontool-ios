
import Foundation
import MapKit
import UserNotifications

class DepartureNotificationManager {
    
    class func notifyUserToDepartForRaid(pickupCoordinate: CLLocationCoordinate2D,
                                         destinationCoordinate: CLLocationCoordinate2D,
                                         destinationName: String,
                                         meetupDate: Date,
                                         identifier: String,
                                         timeStringCompletion: @escaping (String) -> ()) {
        
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        let sourceAnnotation = MKPointAnnotation()
        
        guard let sourceLocation = sourcePlacemark.location else { return }
        sourceAnnotation.coordinate = sourceLocation.coordinate
        
        let destinationAnnotation = MKPointAnnotation()
        guard let destinationLocation = destinationPlacemark.location else { return }
        destinationAnnotation.coordinate = destinationLocation.coordinate
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .walking
        directionRequest.arrivalDate = meetupDate
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculateETA { response, error in
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = "Zeit zum Aufbruch!"
            content.body = "Du musst jetzt los gehen, damit du pünktlich beim Raid bei \(destinationName) ankommst"
            content.sound = UNNotificationSound.default
            
            guard let alarmTime = response?.expectedDepartureDate else { return }
            
            let time = DateUtility.timeString(for: alarmTime)
            let components = Calendar.current.dateComponents([.weekday, .hour, .minute], from: alarmTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            center.add(request)
            print("👫🔔 Notification scheduled at: \(alarmTime)")
            timeStringCompletion(time)
            
            center.getPendingNotificationRequests { requests in
                requests.forEach {
                    print($0.identifier)
                }
            }
        }
        
        NotificationBannerManager.shared.show(.custom, title: "DEBUG", message: "Added Departure Notification")
    }
    
    class func removeUserFromDepartForRaidNotification(for meetupId: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [meetupId])
        print("👫🔔 Removed notification schedule for \(meetupId)")
    }
}
