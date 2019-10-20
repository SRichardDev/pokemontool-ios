
import Foundation

class DateUtility {
    
    class func date(for timeString: String) -> Date? {
        let hoursAndMinutesUntilHatch = timeString.components(separatedBy: ":")
        guard let hours = Int(hoursAndMinutesUntilHatch[0]) else { return nil }
        guard let minutes = Int(hoursAndMinutesUntilHatch[1]) else { return nil }
        let date = Calendar.current.date(bySettingHour: hours,
                                         minute: minutes,
                                         second: 0,
                                         of: Date())
        return date
    }
    
    class func timeStringWithAddedMinutesToDate(minutes: Int, date: Date) -> String {
        let calendar = Calendar.current
        guard let date = calendar.date(byAdding: .minute, value: minutes, to: date) else { return "00:00" }
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        
        let hour = components.hour!
        let minute = components.minute!
        
        var hourString: String
        var minuteString: String
        
        if 0...9 ~= hour {
            hourString = "0\(hour)"
        } else {
            hourString = "\(hour)"
        }
        
        if 0...9 ~= minute {
            minuteString = "0\(minute)"
        } else {
            minuteString = "\(minute)"
        }
        
        return "\(hourString):\(minuteString)"
    }
    
    class func timeString(for date: Date) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale.current
        let selectedTime: String = dateFormatter.string(from: date)
        return selectedTime
    }
}

extension Date {
    var timestamp: TimeInterval {
        return self.timeIntervalSince1970.rounded() * 1000
    }
}
