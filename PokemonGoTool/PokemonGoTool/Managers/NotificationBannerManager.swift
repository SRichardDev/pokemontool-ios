
import NotificationBannerSwift

enum NotificationBannerType {
    case connected
    case disconnected
    case firebaseAuthSuccess
    case firebaseAuthFailure
    case addPoi
    case pushRegistration
    case pushNotification
    case addFriend
}

class NotificationBannerManager {
    
    static let shared = NotificationBannerManager()
    private var currentBanner: NotificationBanner? {
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
        case .pushRegistration:
            currentBanner = NotificationBanner(title: "Push Registrierung",
                                               subtitle: "Wähle den Bereich aus für den du Benachrichtigt werden möchtest",
                                               style: .info)
            currentBanner?.autoDismiss = false
            currentBanner?.haptic = .none
        case .pushNotification:
            currentBanner = NotificationBanner(title: title,
                                               subtitle: message,
                                               style: .info)
        case .addFriend:
            currentBanner = NotificationBanner(title: "Freundes Code kopiert",
                                               subtitle: "Kopiere den Code nun in Pokémon GO",
                                               leftView: UIImageView(image: UIImage(named: "addFriend")),
                                               style: .info)
        }
        
        currentBanner?.show()
    }
    
    func dismiss() {
        currentBanner?.dismiss()
    }
}
