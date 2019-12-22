
import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let _ = request.content.userInfo["signup"] {
            createSignupPush(request, withContentHandler: contentHandler)
        }
        
        if let _ = request.content.userInfo["hatch"] {
            createRaidPush(request, withContentHandler: contentHandler)
        }
    }
    
    private func createRaidPush(_ request: UNNotificationRequest,
                                withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        guard let hatch = request.content.userInfo["hatch"] as? String,
              let end = request.content.userInfo["end"] as? String,
              let meetup = request.content.userInfo["meetup"] as? String,
              let raidboss = request.content.userInfo["raidboss"] as? String else { return }
        
        if let bestAttemptContent = bestAttemptContent {
            bestAttemptContent.title = "\(bestAttemptContent.title)"
            
            if let raidbossNumber = Int(raidboss),
                raidbossNumber != 0 {
                let raidbossString = RaidbossManager.shared.pokemon[raidbossNumber - 1].name
                bestAttemptContent.body =
                """
                ⌚️ \(DateUtility.timeString(from: hatch)) - \(DateUtility.timeString(from: end))
                👫 \(DateUtility.timeString(from: meetup)) 🐲 \(raidbossString)
                """
            } else {
                bestAttemptContent.body =
                """
                ⌚️ \(DateUtility.timeString(from: hatch)) - \(DateUtility.timeString(from: end))
                👫 \(DateUtility.timeString(from: meetup))
                """
            }
            contentHandler(bestAttemptContent)
        }
    }
    
    private func createSignupPush(_ request: UNNotificationRequest,
                                  withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        guard let isSignup = request.content.userInfo["signup"] as? String,
              let count = request.content.userInfo["count"] as? String,
              let trainer = request.content.userInfo["trainer"] as? String else { return }
        
        if let bestAttemptContent = bestAttemptContent {
            bestAttemptContent.title = "\(bestAttemptContent.title)"
            
            if isSignup.boolValue {
                bestAttemptContent.body =
                """
                \(trainer) nimmt teil. Gesamt: \(count)
                """
            } else {
                bestAttemptContent.body =
                """
                \(trainer) hat abgesagt. Gesamt: \(count)
                """
            }
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

extension String {
    var boolValue: Bool {
        return (self as NSString).boolValue
    }
}
