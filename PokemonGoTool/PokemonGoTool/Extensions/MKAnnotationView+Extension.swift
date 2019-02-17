
import MapKit

extension MKAnnotationView {
    func addPulsator() {
        let pulsator = Pulsator()
        pulsator.radius = 40.0
        pulsator.position = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
        pulsator.numPulse = 1
        pulsator.zPosition = -1
        pulsator.backgroundColor = UIColor.orange.cgColor
        layer.addSublayer(pulsator)
        pulsator.start()
    }
}