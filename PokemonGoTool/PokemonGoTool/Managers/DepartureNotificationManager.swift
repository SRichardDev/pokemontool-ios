
import Foundation
import MapKit
import UserNotifications

class DepartureNotificationManager {
   
    class func notifyUserToDepartForRaid(pickupCoordinate: CLLocationCoordinate2D,
                                         destinationCoordinate: CLLocationCoordinate2D,
                                         arenaName: String,
                                         meetupDate: Date,
                                         meetupId: String,
                                         timeChanged: Bool = false) {
            
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
            content.body = "Du musst jetzt los gehen, damit du pünktlich beim Raid bei \(arenaName) ankommst"
            content.sound = UNNotificationSound.default
            
            guard let alarmTime = response?.expectedDepartureDate else { return }
            
            let time = DateUtility.timeString(for: alarmTime)
            
            if timeChanged {
                NotificationBannerManager.shared.show(.custom,
                                                      title: "Treffpunkt wurde geändert!",
                                                      message: "Du wirst um \(time) erinnert loszugehen")
            } else {
                NotificationBannerManager.shared.show(.custom,
                                                      title: "Super! Du nimmst teil!",
                                                      message: "Du wirst um \(time) erinnert loszugehen")
            }
            
            
            let components = Calendar.current.dateComponents([.weekday, .hour, .minute], from: alarmTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: meetupId, content: content, trigger: trigger)
            center.add(request)
            print("👫🔔 Notification scheduled at: \(alarmTime)")
        }
    }
    
    class func removeUserFromDepartForRaidNotification(for meetupId: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [meetupId])
        print("👫🔔 Removed notification schedule for \(meetupId)")
    }
}
