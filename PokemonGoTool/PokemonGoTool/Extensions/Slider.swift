
import UIKit

class Degree360Slider: UISlider {
    
    func setup() {
        minimumValue = 0
        maximumValue = 360
        minimumTrackTintColor = .clear
        maximumTrackTintColor = .clear
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 5.0))
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
}
