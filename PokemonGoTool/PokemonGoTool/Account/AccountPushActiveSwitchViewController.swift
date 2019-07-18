
import UIKit
import UserNotifications

class AccountPushActiveSwitchViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: AccountViewModel!

    @IBOutlet var titleLabel: Label!
    @IBOutlet var pushActiveSwitch: UISwitch!
    @IBOutlet var pushStatusLabel: Label!
    @IBOutlet var goToSettingsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        goToSettingsButton.setTitle("Zu den Einstellungen", for: .normal)
        goToSettingsButton.addAction {
            UIApplication.openAppSettings()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePushStatus()
    }
    
    @objc
    func didBecomeActive() {
        updatePushStatus()
    }
    
    func updatePushStatus() {
        pushActiveSwitch.isOn = viewModel.isPushActivated
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    self.showSystemPushActivated()
                } else {
                    self.showSystemPushDeactivated()
                }
            }
        }
    }
    
    func showSystemPushActivated() {
        pushStatusLabel.isHidden = true
        pushActiveSwitch.isEnabled = true
        goToSettingsButton.isHidden = true
    }
    
    func showSystemPushDeactivated() {
        pushStatusLabel.text = "Push Nachrichten sind nicht aktiv. Bitte in den Einstellungen Mitteilungen für PoGO Radar aktivieren, um Benachrichtigungen für Raids und Feldforschungen zu bekommen."
        pushStatusLabel.textColor = .red
        pushStatusLabel.isHidden = false
        pushActiveSwitch.isEnabled = false
        pushActiveSwitch.isOn = false
        goToSettingsButton.isHidden = false
    }
    
    @IBAction func pushActiveSwitchDidChange(_ sender: UISwitch) {
        viewModel.pushActivatedChanged(sender.isOn)
        AppSettings.isPushActive = sender.isOn
        showSystemPushActivated()
    }
}
