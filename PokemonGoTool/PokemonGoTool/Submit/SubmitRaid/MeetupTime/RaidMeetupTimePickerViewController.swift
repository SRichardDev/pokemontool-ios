
import UIKit

class RaidMeetupTimePickerViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: MeetupTimeSelectable!
    @IBOutlet var titleLabel: Label!
    @IBOutlet var pickerView: UIDatePicker!
    @IBOutlet var submitMeetupTimeButton: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Treffpunkt:"
        pickerView.datePickerMode = .time
        pickerView.timeZone = TimeZone.current
        submitMeetupTimeButton.setTitle("Bestätigen", for: .normal)
        submitMeetupTimeButton.isHidden = viewModel.meetupTimeSelectionType == .initial
        
        let originalDate = Date()
        viewModel.selectedMeetupTime = originalDate.timestamp
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .minute,
                                    value: 0,
                                    to: originalDate,
                                    wrappingComponents: false)
        let maxDate = calendar.date(byAdding: .minute,
                                    value: 105,
                                    to: originalDate,
                                    wrappingComponents: false)
        pickerView.minimumDate = minDate
        pickerView.maximumDate = maxDate
    }
    
    @IBAction func timePickerDidChange(_ sender: UIDatePicker) {
        let timeinterval = sender.date.timestamp
        viewModel.selectedMeetupTime = timeinterval
    }
    
    private func selectedTime(date: Date) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale.current
        let selectedTime: String = dateFormatter.string(from: date)
        return selectedTime
    }
        
    @IBAction func didTapSubmitMeetupTime(_ sender: Any) {
        viewModel.meetupTimeDidChange()
    }
}
