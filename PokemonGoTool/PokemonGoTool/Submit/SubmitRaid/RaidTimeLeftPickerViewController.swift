
import UIKit

class RaidTimeLeftPickerViewController: UIViewController, StoryboardInitialViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var viewModel: SubmitRaidViewModel!
    @IBOutlet var titleLabel: Label!
    @IBOutlet var selectedTimeLabel: Label!
    @IBOutlet var pickerView: UIPickerView!
    
    var pickerViewRows: [String] {
        get {
            var array = [String]()
            array.reserveCapacity(45)
            for index in 0...45 {
                array.append("\(index) min")
            }
            return array
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    //MARK: UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerViewRows[row]
    }
    
    //MARK: UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerViewRows.count
    }
    
    @IBAction func timePickerDidChange(_ sender: UIDatePicker) {
//        viewModel.selectedTime = selectedTime(date: sender.date)
//        selectedTimeLabel.text = viewModel.selectedTime
    }
    
    private func selectedTime(date: Date) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale.current
        let selectedTime: String = dateFormatter.string(from: date)
        return selectedTime
    }
}
