
import UIKit

class RaidPickerViewController: UIViewController, StoryboardInitialViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var viewModel: SubmitRaidViewModel!
    @IBOutlet var titleLabel: Label!
    @IBOutlet var pickerView: UIDatePicker!
    
    let pickerViewRows = ["First row,", "Secound row,","Third row,","Fourth row"]

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.datePickerMode = .time
        pickerView.timeZone = TimeZone.current
        let originalDate = Date()
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .minute, value: -90, to: originalDate, wrappingComponents: false)
        let maxDate = calendar.date(byAdding: .minute, value: 90, to: originalDate, wrappingComponents: false)
        pickerView.minimumDate = minDate
        pickerView.maximumDate = maxDate
    }
    
    //MARK: UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerViewRows[row]
    }
    
    //MARK: UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 20
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerViewRows.count
    }
}
