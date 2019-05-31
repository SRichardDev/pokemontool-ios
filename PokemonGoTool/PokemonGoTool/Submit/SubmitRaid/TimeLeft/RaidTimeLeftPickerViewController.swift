
import UIKit

class RaidTimeLeftPickerViewController: UIViewController, StoryboardInitialViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var viewModel: SubmitRaidViewModel!
    @IBOutlet var titleLabel: Label!
    @IBOutlet var pickerView: UIPickerView!
    
    var pickerViewRows: [String] {
        get {
            var array = [String]()
            array.reserveCapacity(45)
            for index in 1...45 {
                array.append("\(index)")
            }
            return array.reversed()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Wieviele Minuten läuft der Raid noch?"
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerViewRows[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.selectedTimeLeft = pickerViewRows[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerViewRows.count
    }
}
