
import UIKit

class RaidMeetupTimePickerViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: SubmitRaidViewModel!
    @IBOutlet var titleLabel: Label!
    @IBOutlet var selectedTimeLabel: Label!
    @IBOutlet var pickerView: UIDatePicker!
    
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
        selectedTimeLabel.text = selectedTime(date: pickerView.date)
    }
    
    @IBAction func timePickerDidChange(_ sender: UIDatePicker) {
        viewModel.selectedTime = selectedTime(date: sender.date)
        selectedTimeLabel.text = viewModel.selectedTime
    }
    
    private func selectedTime(date: Date) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale.current
        let selectedTime: String = dateFormatter.string(from: date)
        return selectedTime
    }
}
