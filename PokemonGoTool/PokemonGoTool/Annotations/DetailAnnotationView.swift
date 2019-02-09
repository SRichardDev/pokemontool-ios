
import UIKit

class DetailAnnotationView: UIView {
    
    @IBOutlet private var annotationImageView: UIImageView!
    @IBOutlet private var annotationNameLabel: Label!
    @IBOutlet private var annotationTypeLabel: Label!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var buttonsStackView: UIStackView!
    
    var annotation: Annotation!
    weak var delegate: DetailAnnotationViewDelegate?
    
    func configure(with annotation: Annotation) {
        self.annotation = annotation
        annotationNameLabel.text = annotation.name
        
        if annotation is Pokestop {
            annotationTypeLabel.text = "Pokéstop"
            annotationImageView.image = UIImage(named: "PokestopLarge")
            let questButton = Button()
            let detailsButton = Button()
            questButton.setTitle("Neue Quest", for: .normal)
            questButton.addTarget(self, action: #selector(DetailAnnotationView.showAnnotationInfoTapped(_:)), for: .touchUpInside)
            detailsButton.setTitle("Details", for: .normal)
            buttonsStackView.addArrangedSubview(questButton)
            buttonsStackView.addArrangedSubview(detailsButton)
        } else if let annotation = annotation as? Arena {
            annotationTypeLabel.text = annotation.isEX ? "EX Arena" : "Arena"
            annotationImageView.image = annotation.isEX ? UIImage(named: "arenaEX") : UIImage(named: "arena")
            let raidButton = Button()
            let detailsButton = Button()
            raidButton.setTitle("Neuer Raid", for: .normal)
            raidButton.addTarget(self, action: #selector(DetailAnnotationView.showAnnotationInfoTapped(_:)), for: .touchUpInside)
            detailsButton.setTitle("Details", for: .normal)
            buttonsStackView.addArrangedSubview(raidButton)
            buttonsStackView.addArrangedSubview(detailsButton)
        }
    }
    
    @objc
    func showAnnotationInfoTapped(_ sender: Any) {
        delegate?.showDetail(for: annotation)
    }
}
