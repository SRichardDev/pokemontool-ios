
import UIKit
import NotificationBannerSwift

extension FirebaseStatusPresentable where Self: UIViewController {
    
    func showAlert(for status: AuthStatus) {
        
        var title = "Error"
        var message = ""
        var bannerType: NotificationBannerType = .firebaseAuthSuccess
        switch status {
        case .weakPassword:
            title = "Fehler"
            message = "Schwaches Passwort! Bitte verwende ein sicheres Passwort!"
            bannerType = .firebaseAuthFailure
        case .invalidCredential:
            title = "Fehler"
            message = "Ungültige Eingabe"
            bannerType = .firebaseAuthFailure
        case .emailAlreadyInUse:
            title = "Fehler"
            message = "Diese E-Mail Adresse ist schon registriert. Falls du dein Passwort vergessen hast, musst du dein Passwort zurücksetzen"
            bannerType = .firebaseAuthFailure
        case .invalidEmail:
            title = "Fehler"
            message = "Ungültige E-Mail Adresse"
            bannerType = .firebaseAuthFailure
        case .networkError:
            title = "Fehler"
            message = "Es besteht keine Verbindung zum Internet"
            bannerType = .firebaseAuthFailure
        case .missingEmail:
            title = "Fehler"
            message = "Fehlende E-Mail Adresse"
            bannerType = .firebaseAuthFailure
        case .unknown(let error):
            title = "Fehler"
            message = error
            bannerType = .firebaseAuthFailure
        case .signedUp:
            title = "Erfolgreich"
            message = "Bitte bestätige die Verifizierungs E-Mail die dir zugesendet wurde"
            bannerType = .firebaseAuthSuccess
        case .signedIn:
            title = "Erfolgreich angemeldet"
            message = "Willkommen zurück Trainer!"
            bannerType = .firebaseAuthSuccess
        case .signedOut:
            title = "Erfolgreich abgemeldet"
            message = "Bis bald Trainer!"
            bannerType = .firebaseAuthSuccess
        }
        
        guard message != "No Result" else { return }
        
        NotificationBannerManager.shared.show(bannerType, title: title, message: message)
    }
}
