
import UIKit

class RaidHatchTimePickerViewController: UIViewController, StoryboardInitialViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var viewModel: SubmitRaidViewModel!
    @IBOutlet var titleLabel: Label!
    @IBOutlet var hatchTimePointPicker: UIDatePicker!
    @IBOutlet var timeLeftEggHatchesPicker: UIPickerView!
    @IBOutlet var timeFormatSegmentedControl: UISegmentedControl!
    
    var pickerViewRows: [String] {
        get {
            var array = [String]()
            array.reserveCapacity(60)
            for index in 1...60 {
                array.append("\(index)")
            }
            return array.reversed()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "Schlüpft:"
        
        timeLeftEggHatchesPicker.delegate = self
        timeLeftEggHatchesPicker.dataSource = self
        
        timeFormatSegmentedControl.setTitle("Zeitpunkt", forSegmentAt: 0)
        timeFormatSegmentedControl.setTitle("Zeitspanne", forSegmentAt: 1)
        timeFormatSegmentedControl.isHidden = true
        
        hatchTimePointPicker.datePickerMode = .time
        hatchTimePointPicker.timeZone = TimeZone.current
        let currentDate = Date()
//        viewModel.selectedHatchTime = selectedTime(date: currentDate)
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .minute, value: -60, to: currentDate, wrappingComponents: false)
        let maxDate = calendar.date(byAdding: .minute, value: 60, to: currentDate, wrappingComponents: false)
        hatchTimePointPicker.minimumDate = minDate
        hatchTimePointPicker.maximumDate = maxDate
    }
    
    @IBAction func timePickerDidChange(_ sender: UIDatePicker) {
//        let timeDifference = Calendar.current.dateComponents([.minute], from: Date(), to: sender.date)
//        viewModel.selectedHatchTime = selectedTime(date: sender.date)
    }
    
    @IBAction func timeFormatSegmentedControlDidChange(_ sender: UISegmentedControl) {
        hatchTimePointPicker.isVisible = sender.selectedSegmentIndex == 0
        timeLeftEggHatchesPicker.isVisible = sender.selectedSegmentIndex == 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerViewRows[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        viewModel.selectedHatchTime = pickerViewRows[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerViewRows.count
    }
    
    private func selectedTime(date: Date) -> String {
        return DateUtility.timeString(for: date)
    }
}
