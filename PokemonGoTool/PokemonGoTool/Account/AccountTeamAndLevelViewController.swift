
import UIKit

class AccountTeamAndLevelViewController: UIViewController, StoryboardInitialViewController {

    weak var coordinator: MainCoordinator?
    
    var signUpViewModel: SignUpViewModel?
    var accountViewModel: AccountViewModel?

    @IBOutlet var trainerNameTitleLabel: Label!
    @IBOutlet var trainerNameTextField: UITextField!
    @IBOutlet var teamTitleLabel: Label!
    @IBOutlet var teamSelectionSegmentedControl: UISegmentedControl!
    @IBOutlet var levelTitleLabel: Label!
    @IBOutlet var levelPickerView: UIPickerView!
    @IBOutlet var trainerCodeTitleLabel: Label!
    @IBOutlet var trainerCodeTextField: UITextField!
    @IBOutlet var nextButton: Button!
    
    var teamPickerViewRows: [String] {
        get {
            var array = [String]()
            array.reserveCapacity(40)
            for index in 1...40 {
                array.append("\(index)")
            }
            return array.reversed()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Team & Level"
        levelPickerView.delegate = self
        levelPickerView.dataSource = self
        trainerNameTitleLabel.isVisible = accountViewModel != nil
        trainerNameTextField.isVisible = accountViewModel != nil
        trainerCodeTitleLabel.isVisible = accountViewModel != nil
        trainerCodeTextField.isVisible = accountViewModel != nil
        nextButton.isHidden = accountViewModel != nil
        
        trainerNameTextField.placeholder = "Trage hier deine Namen ein"
        trainerCodeTextField.placeholder = "Trage hier deinen Freundescode ein"
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        accountViewModel?.updateTrainerName(trainerNameTextField.text ?? "")
        accountViewModel?.updateTrainerCode(trainerCodeTextField.text ?? "")
    }
    
    func updateUI() {
        guard let viewModel = accountViewModel else { return }
        trainerNameTextField.text = viewModel.trainerName
        teamSelectionSegmentedControl.selectedSegmentIndex = viewModel.currentTeam?.rawValue ?? 0
        teamSelectionSegmentedControl.tintColor = viewModel.currentTeam?.color
        trainerCodeTextField.text = viewModel.trainerCode
        levelPickerView.selectRow(40 - viewModel.currentLevel, inComponent: 0, animated: false)
    }
    
    @IBAction func doneTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func didSelectTeam(_ sender: UISegmentedControl) {
        guard let team = Team(rawValue: sender.selectedSegmentIndex) else { return }
        sender.tintColor = team.color
        
        if let viewModel = accountViewModel {
            viewModel.updateTeam(team)
        } else if let viewModel = signUpViewModel {
            viewModel.team = team
        }
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        guard let viewModel = signUpViewModel else { return }
        coordinator?.showSignUp(viewModel)
    }
}

extension AccountTeamAndLevelViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return teamPickerViewRows[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let level = Int(teamPickerViewRows[row]) ?? 1
        
        if let viewModel = accountViewModel {
            viewModel.updateLevel(level)
        } else if let viewModel = signUpViewModel {
            viewModel.level = level
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return teamPickerViewRows.count
    }
}
