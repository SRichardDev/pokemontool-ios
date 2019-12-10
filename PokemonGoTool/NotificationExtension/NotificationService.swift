
import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        let hatchTimestamp = request.content.userInfo["hatch"] as! Double
        let hatchDate = Date(timeIntervalSince1970: hatchTimestamp/1000)
        let hatchDateString = DateUtility.timeString(for: hatchDate)
        
        let endTimestamp = request.content.userInfo["end"] as! Double
        let endDate = Date(timeIntervalSince1970: endTimestamp/1000)
        let endDateString = DateUtility.timeString(for: endDate)

        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            bestAttemptContent.body = "\(hatchDateString) - \(endDateString)"
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
