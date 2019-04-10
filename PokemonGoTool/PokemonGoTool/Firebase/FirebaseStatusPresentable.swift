
import UIKit
import NotificationBannerSwift

extension FirebaseStatusPresentable where Self: UIViewController {
    
    func showAlert(for status: AuthStatus) {
        
        var title = "Error"
        var message = ""
        var bannerStyle: BannerStyle = .none
        switch status {
        case .weakPassword:
            title = "Fehler"
            message = "Schwaches Passwort! Bitte verwende ein sicheres Passwort!"
            bannerStyle = .danger
        case .invalidCredential:
            title = "Fehler"
            message = "Ungültige Eingabe"
            bannerStyle = .danger
        case .emailAlreadyInUse:
            title = "Fehler"
            message = "Diese E-Mail Adresse ist schon registriert. Falls du dein Passwort vergessen hast, musst du dein Passwort zurücksetzen"
            bannerStyle = .danger
        case .invalidEmail:
            title = "Fehler"
            message = "Ungültige E-Mail Adresse"
            bannerStyle = .danger
        case .networkError:
            title = "Fehler"
            message = "Es besteht keine Verbindung zum Internet"
            bannerStyle = .danger
        case .missingEmail:
            title = "Fehler"
            message = "Fehlende E-Mail Adresse"
            bannerStyle = .danger
        case .unknown(let error):
            title = "Fehler"
            message = error
            bannerStyle = .danger
        case .signedUp:
            title = "Erfolgreich"
            message = "Bitte bestätige die Verifizierungs E-Mail die dir zugesendet wurde"
            bannerStyle = .success
        case .signedIn:
            title = "Erfolgreich angemeldet"
            message = "Willkommen zurück Trainer!"
            bannerStyle = .success
        case .signedOut:
            title = "Erfolgreich abgemeldet"
            message = "Bis bald Trainer!"
            bannerStyle = .success
        }
        
        guard message != "No Result" else { return }
        let banner = NotificationBanner(title: title, subtitle: message, style: bannerStyle)
        banner.show()

    }
}
