
import UIKit

class AccountDetailsViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: AccountViewModel!
    
    @IBOutlet var trainerNameTitleLabel: Label!
    @IBOutlet var trainerNameTextField: UITextField!
    @IBOutlet var teamTitleLabel: Label!
    @IBOutlet var teamSelectionSegmentedControl: UISegmentedControl!
    @IBOutlet var levelTitleLabel: Label!
    @IBOutlet var levelPickerView: UIPickerView!
    @IBOutlet var trainerCodeTitleLabel: Label!
    @IBOutlet var trainerCodeTextField: UITextField!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        trainerNameTitleLabel.text = "Trainer-Name:"
        teamTitleLabel.text = "Team:"
        levelTitleLabel.text = "Level:"
        trainerCodeTitleLabel.text = "Freundes-Code:"
        
        levelPickerView.delegate = self
        levelPickerView.dataSource = self
        
        trainerNameTextField.placeholder = "Trage hier deine Trainer-Namen ein"
        trainerCodeTextField.placeholder = "Trage hier deinen Freunde-Code ein"
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let trainerName = trainerNameTextField.text else { return }
        guard let trainerCode = trainerCodeTextField.text else { return }
        viewModel.updateTrainerName(trainerName)
        viewModel.updateTrainerCode(trainerCode)
    }
    
    func updateUI() {
        trainerNameTextField.text = viewModel.trainerName
        trainerCodeTextField.text = viewModel.trainerCode
        teamSelectionSegmentedControl.selectedSegmentIndex = viewModel.currentTeam!.rawValue
        levelPickerView.selectRow(40 - viewModel.currentLevel, inComponent: 0, animated: false)
        teamSelectionSegmentedControl.tintColor = viewModel.currentTeam?.color
    }
    
    @IBAction func doneTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func didSelectTeam(_ sender: UISegmentedControl) {
        guard let team = Team(rawValue: sender.selectedSegmentIndex) else { return }
        viewModel.updateTeam(team)
        sender.tintColor = team.color
    }
    
    @IBAction func viewTapped(_ sender: Any) {
        trainerNameTextField.resignFirstResponder()
        trainerCodeTextField.resignFirstResponder()
    }
}

extension AccountDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Team.pickerRows[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.updateLevel(Int(Team.pickerRows[row]) ?? 40)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Team.pickerRows.count
    }
}
