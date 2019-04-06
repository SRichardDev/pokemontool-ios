
import UIKit

class AccountDetailsViewController: UIViewController, StoryboardInitialViewController {

    var viewModel: AccountViewModel!
    
    @IBOutlet var teamTitleLabel: Label!
    @IBOutlet var teamSelectionSegmentedControl: UISegmentedControl!
    @IBOutlet var levelTitleLabel: Label!
    @IBOutlet var levelPickerView: UIPickerView!
    
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
        levelPickerView.delegate = self
        levelPickerView.dataSource = self
    }
    
    func updateUI() {
        teamSelectionSegmentedControl.selectedSegmentIndex = viewModel.currentTeam
        teamSelectionSegmentedControl.tintColor = viewModel.teamColor
        levelPickerView.selectRow(viewModel.currentLevel, inComponent: 0, animated: false)
    }
    
    @IBAction func didSelectTeam(_ sender: UISegmentedControl) {
        guard let team = Team(rawValue: sender.selectedSegmentIndex) else { return }
        sender.tintColor = viewModel.updateTeam(team)
    }
}

extension AccountDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return teamPickerViewRows[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.updateLevel(Int(teamPickerViewRows[row]) ?? 0)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return teamPickerViewRows.count
    }
}
