
import NotificationBannerSwift
import MapKit

enum NotificationBannerType {
    case connected
    case disconnected
    case firebaseAuthSuccess
    case firebaseAuthFailure
    case addPoi
    case pushRegistration
    case pushNotification
    case addFriend
    case unregisteredUser
    case questSubmitted
    case mapTypeChanged(mapType: MKMapType)
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
                                               style: .success)
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
            currentBanner = NotificationBanner(title: "Freundes-Code kopiert",
                                               subtitle: "Füge den Code nun in Pokémon GO ein",
                                               leftView: UIImageView(image: UIImage(named: "addFriend")),
                                               style: .info)
        case .unregisteredUser:
            currentBanner = NotificationBanner(title: "Fehler",
                                               subtitle: "Bitte registriere dich um diese Funktion zu nutzen",
                                               leftView: UIImageView(image: UIImage(named: "cross")),
                                               style: .danger)
        case .questSubmitted:
            currentBanner = NotificationBanner(title: "Vielen Dank!",
                                               subtitle: "Die Feldforschung wurde eingereicht",
                                               leftView: UIImageView(image: UIImage(named: "checkmark")),
                                               style: .success)
        case .mapTypeChanged(mapType: let mapType):
            
            let imageView = UIImageView(image: UIImage(named: "mapMenuMap"))
            imageView.tintColor = .white
                
            currentBanner = NotificationBanner(title: "Kartentyp geändert",
                                               subtitle: mapType.description,
                                               leftView: imageView,
                                               style: .info)
        }
        
        currentBanner?.show()
    }
    
    func dismiss() {
        currentBanner?.dismiss()
    }
}
