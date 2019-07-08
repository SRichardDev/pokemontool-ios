
import UIKit

enum AccountInputType {
    case email
    case password
    case trainerName
    case emailSignIn
    case passwordSignIn
    case team
    case level
}

class AccountInputViewController: UIViewController, StoryboardInitialViewController, AccountSignInDelegate, FirebaseStatusPresentable {
    
    weak var coordinator: MainCoordinator?
    var viewModel: SignUpViewModel!
    var type: AccountInputType = .email
    
    @IBOutlet var subtitleLabel: Label!
    @IBOutlet var textField: UITextField!
    @IBOutlet var forgotPasswordButton: UIButton!
    @IBOutlet var nextButton: Button!
    @IBOutlet var textInputStackView: InnerVerticalStackView!
    @IBOutlet var teamStackView: InnerVerticalStackView!
    @IBOutlet var levelStackView: InnerVerticalStackView!
    @IBOutlet var levelPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.accountSignInDelegate = self
        nextButton.isEnabled = false
        textInputStackView.isHidden = true
        forgotPasswordButton.isHidden = true
        teamStackView.isHidden = true
        levelStackView.isHidden = true
        levelPickerView.delegate = self
        levelPickerView.dataSource = self
        
        forgotPasswordButton.addAction { [unowned self] in
            self.viewModel.resetPassword()
        }

        switch type {
        case .email:
            title = "E-Mail"
            subtitleLabel.text = "Um einen Account zu erstellen benötigen wir eine gültige E-Mail Adresse von dir. Bitte achte darauf, dass die E-Mail Adresse korrekt ist, da du von uns eine Bestätigungs-E-Mail bekommst."
            textField.placeholder = "Trage hier deine E-Mail Adresse ein"
            textField.textContentType = .emailAddress
            textInputStackView.isHidden = false
        case .password:
            title = "Passwort"
            subtitleLabel.text = "Bitte wähle ein Passwort aus. Dieses muss mindestens 6 Zeichen lang sein und muss aus mindestens drei Buchstaben und drei Zahlen bestehen."
            textField.placeholder = "Trage hier dein Passwort ein"
            textField.textContentType = .newPassword
            textField.isSecureTextEntry = true
            textInputStackView.isHidden = false
        case .trainerName:
            title = "Trainer Name"
            subtitleLabel.text = "Bitte gebe deinen Trainer Namen ein, den du auch im Spiel verwendest."
            textField.placeholder = "Trage hier deinen Trainer Namen ein"
            textInputStackView.isHidden = false
            textField.textContentType = .none
        case .emailSignIn:
            title = "E-Mail"
            subtitleLabel.text = "Bitte gebe deine E-Mail Adresse ein, mit der du dich für diese App registriert hast."
            textField.placeholder = "Trage hier deine E-Mail Adresse ein"
            textInputStackView.isHidden = false
        case .passwordSignIn:
            title = "Passwort"
            subtitleLabel.text = "Jetzt noch dein Passwort und dann kann es los gehen."
            textField.placeholder = "Trage hier dein Passwort ein"
            nextButton.setTitle("Anmelden", for: .normal)
            textField.textContentType = .password
            textField.isSecureTextEntry = true
            textInputStackView.isHidden = false
            forgotPasswordButton.isHidden = false
        case .team:
            title = "Team"
            teamStackView.isHidden = false
            nextButton.isEnabled = true
        case .level:
            title = "Level"
            levelStackView.isHidden = false
            nextButton.isEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func doneTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
        verifyInput(sender.text)
    }
    
    @IBAction func viewTapped(_ sender: Any) {
        textField.resignFirstResponder()
        verifyInput(textField.text)
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        switch type {
        case .email:
            coordinator?.showAccountInput(viewModel, type: .password)
        case .password:
            coordinator?.showAccountInput(viewModel, type: .trainerName)
        case .trainerName:
            coordinator?.showAccountInput(viewModel, type: .team)
        case .emailSignIn:
            coordinator?.showAccountInput(viewModel, type: .passwordSignIn)
        case .passwordSignIn:
            viewModel.signInUser()
            showSpinner()
        case .team:
            coordinator?.showAccountInput(viewModel, type: .level)
        case .level:
            coordinator?.showSignUp(viewModel)
        }
    }
    
    @IBAction func teamDidChange(_ sender: UISegmentedControl) {
        guard let team = Team(rawValue: sender.selectedSegmentIndex) else { return }
        viewModel.team = team
        sender.tintColor = team.color
    }
    
    
    func didSignInUser(_ status: AuthStatus) {
        showAlert(for: status)
        removeSpinner()

        switch status {
        case .signedIn:
            navigationController?.popToRootViewController(animated: true)
        default:
            break
        }
    }
    
    func failedToSignIn(_ status: AuthStatus) {
        showAlert(for: status)
        removeSpinner()
    }
    
    private func verifyInput(_ inputText: String?) {
        guard let inputText = inputText else { return }
        switch type {
        case .email, .emailSignIn:
            let trimmedEmail = inputText.trimmingTrailingSpaces
            nextButton.isEnabled = viewModel.isValidEmail(trimmedEmail)
            viewModel.email = trimmedEmail
        case .password, .passwordSignIn:
            nextButton.isEnabled = viewModel.isValidPassword(inputText)
            viewModel.password = inputText
        case .trainerName:
            nextButton.isEnabled = inputText != ""
            viewModel.trainerName = inputText
        case .team, .level:
            break
        }
    }
}

extension AccountInputViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Team.pickerRows[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.level = Int(Team.pickerRows[row]) ?? 40
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Team.pickerRows.count
    }
}

extension String {
    var trimmingTrailingSpaces: String {
        if let range = rangeOfCharacter(from: .whitespacesAndNewlines, options: [.anchored, .backwards]) {
            return String(self[..<range.lowerBound]).trimmingTrailingSpaces
        }
        return self
    }
}
