
import UIKit

class DepartureNotificationSwitchViewController: UIViewController, StoryboardInitialViewController {
        
    var viewModel: ArenaDetailsViewModel!

    @IBOutlet var titleLabel: Label!
    @IBOutlet var detailsLabel: Label!
    @IBOutlet var switchControl: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Aufbruch Benachrichtigung:"
        updateUI()
    }
    
    func updateUI() {
        switchControl.isOn = viewModel.isDepartureNotificationSet
        switchControl.isEnabled = viewModel.isTimeSetForMeetup

        if viewModel.isTimeSetForMeetup {
            if let time = viewModel.departureNotificationTime {
                detailsLabel.textWithAnimation(text: "Du wirst um \(time) benachrichtigt loszugehen.", duration: 0.25)
            } else {
                detailsLabel.textWithAnimation(text: "PoGO Radar wird dich benachrichtigen, wenn es Zeit zum losgehen ist, damit du pünktlich zum Raid erscheinst. Achtung: Die Berechnung der Wegzeit wird von deinem aktuellen Standort abhängig gemacht. Aktiviere diese Funktion nur, falls du dich bis zum Aufbruch immer noch am selben Ort befindest.", duration: 0.25)
            }
        } else {
            detailsLabel.textWithAnimation(text: "Der Treffpunkt muss gesetzt sein bevor du benachrichtigt werden kannst.", duration: 0.25)
        }
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if sender.isOn {
            viewModel.addDepartureNotification() { (time, error) in
                if let error = error {
                    sender.isOn = false
                    self.detailsLabel.textColor = .red
                    switch error.type {
                    case .userLocationNotFound:
                        self.detailsLabel.textWithAnimation(text: "Fehler: Deine Position konnte nicht ermittelt werden.", duration: 0.25)
                    }
                } else {
                    self.detailsLabel.textColor = .lightGray
                    self.detailsLabel.textWithAnimation(text: "Du wirst um \(time) benachrichtigt loszugehen.", duration: 0.25)
                }
            }
        } else {
            viewModel.removeDepartureNotification()
            updateUI()
        }
    }
}
