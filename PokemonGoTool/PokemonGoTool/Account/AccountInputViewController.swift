
import UIKit

enum AccountCreationInputType {
    case email
    case password
    case trainerName
}

class AccountInputViewController: UIViewController, StoryboardInitialViewController {
    
    weak var coordinator: MainCoordinator?
    var viewModel: AccountViewModel!
    var type: AccountCreationInputType = .email
    
    @IBOutlet var subtitleLabel: Label!
    @IBOutlet var textField: UITextField!
    @IBOutlet var nextButton: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.isEnabled = false
        
        switch type {
        case .email:
            title = "E-Mail"
            subtitleLabel.text = "Um einen Account zu erstellen benötigen wir eine gültige E-Mail Adresse von dir. Bitte achte darauf, dass die E-Mail Adresse korrekt ist, da du von uns eine Bestätigungs-E-Mail bekommst."
            textField.placeholder = "Trage hier deine E-Mail Adresse ein"
        case .password:
            title = "Passwort"
            subtitleLabel.text = "Bitte wähle ein Passwort aus. Dieses muss mindestens 6 Zeichen lang sein und muss aus Buchstaben und Zahlen bestehen."
            textField.placeholder = "Trage hier dein Passwort ein"
        case .trainerName:
            title = "Trainer Name"
            subtitleLabel.text = "Bitte gebe deinen Trainer Namen ein, den du auch im Spiel verwendest."
            textField.placeholder = "Trage hier deinen Trainer Namen ein"
        }
    }
    
    @IBAction func doneTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
        verifyInput(sender.text)
    }
    
    @IBAction func viewTapped(_ sender: Any) {
        textField.resignFirstResponder()
        verifyInput(textField.text)
    }
    
    @IBAction func nextTapped(_ sender: Button) {
        switch type {
        case .email:
            coordinator?.showAccountInput(viewModel, type: .password)
        case .password:
            coordinator?.showAccountInput(viewModel, type: .trainerName)
        case .trainerName:
            coordinator?.showTeamAndLevel(viewModel)
        }
    }
    
    private func verifyInput(_ inputText: String?) {
        guard let inputText = inputText else { return }
        switch type {
        case .email:
            nextButton.isEnabled = isValidEmail(inputText)
            viewModel.email = inputText
        case .password:
            nextButton.isEnabled = isValidPassword(inputText)
            viewModel.password = inputText
        case .trainerName:
            nextButton.isEnabled = inputText != ""
        }
    }
    
    private func isValidEmail(_ testString: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testString)
    }
    
    private func isValidPassword(_ testString: String) -> Bool {
        let passwordRegex = "^(?=.*[0-9].*[0-9].*[0-9])(?=.*[a-z].*[a-z].*[a-z]).{6,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: testString)
    }
}
