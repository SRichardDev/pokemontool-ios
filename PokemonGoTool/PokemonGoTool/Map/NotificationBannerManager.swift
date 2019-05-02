
import NotificationBannerSwift

enum NotificationBannerType {
    case connected
    case disconnected
    case firebaseAuthSuccess
    case firebaseAuthFailure
    case addPoi
    case pushRegistraiton
    case pushNotification
}

class NotificationBannerManager {
    
    static let shared = NotificationBannerManager()
    var currentBanner: NotificationBanner? {
        willSet {
            currentBanner?.dismiss()
        }
    }
    
    private init() {}
    
    func show(_ type: NotificationBannerType, title: String? = nil, message: String? = nil) {
        
        switch type {
            
        case .connected:
            currentBanner = NotificationBanner(title: "Vebunden zum Server",
                                               subtitle: "Viel Spaß Trainer!",
                                               leftView: UIImageView(image: UIImage(named: "checkmark")),
                                               style: .success)
        case .disconnected:
            currentBanner = NotificationBanner(title: "Keine Verbindung zum Server",
                                               subtitle: "Prüfe bitte deine Internetverbindung",
                                               leftView: UIImageView(image: UIImage(named: "cross")),
                                               style: .danger)
        case .firebaseAuthSuccess:
            currentBanner = NotificationBanner(title: title,
                                               subtitle: message,
                                               style: .danger)
        case .firebaseAuthFailure:
            currentBanner = NotificationBanner(title: title,
                                               subtitle: message,
                                               style: .danger)
        case .addPoi:
            currentBanner = NotificationBanner(title: "Pokéstop / Arena hinzufügen",
                                               subtitle: "Schiebe die Karte um die Position anzupassen",
                                               style: .info)
            currentBanner?.autoDismiss = false
            currentBanner?.haptic = .none
        case .pushRegistraiton:
            currentBanner = NotificationBanner(title: "Push Registrierung",
                                               subtitle: "Wähle den Bereich aus für den du Benachrichtigt werden möchtest",
                                               style: .info)
        case .pushNotification:
            currentBanner = NotificationBanner(title: title,
                                               subtitle: message,
                                               style: .info)
        }
        
        currentBanner?.show()
    }
    
    func dismiss() {
        currentBanner?.dismiss()
    }
}
