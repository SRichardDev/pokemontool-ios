
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

