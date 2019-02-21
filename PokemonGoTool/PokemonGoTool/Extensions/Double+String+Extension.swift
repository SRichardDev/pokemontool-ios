
import Foundation

extension Double {
    var string: String {
        return "\(self)"
    }
}

extension String {
    var double: Double {
        return Double(self) ?? 0.0
    }
}

extension Double {
    func getDateStringFromUnixTime(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: Date(timeIntervalSince1970: self))
    }
}
