
import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let hatch = request.content.userInfo["hatch"] as? String,
              let end = request.content.userInfo["end"] as? String,
              let meetup = request.content.userInfo["meetup"] as? String else { return }

        if let bestAttemptContent = bestAttemptContent {
            bestAttemptContent.title = "\(bestAttemptContent.title)"
            bestAttemptContent.body =
            """
            ⌚️ \(timeString(from: hatch)) - \(timeString(from: end))
            👫 \(timeString(from: meetup))
            """
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    private func timeString(from input: String) -> String {
        guard let timestamp = Double(input) else { return "--:--" }
        let date = Date(timeIntervalSince1970: timestamp/1000)
        let dateString = DateUtility.timeString(for: date)
        return dateString
    }
}
