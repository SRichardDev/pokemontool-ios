
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
            questButton.addTarget(self,
                                  action: #selector(DetailAnnotationView.showAnnotationSubmitDetailTapped(_:)),
                                  for: .touchUpInside)
            detailsButton.setTitle("Details", for: .normal)
            detailsButton.addTarget(self,
                                    action: #selector(DetailAnnotationView.showAnnotationInfoDetailTapped(_:)),
                                    for: .touchUpInside)
            buttonsStackView.addArrangedSubview(questButton)
            buttonsStackView.addArrangedSubview(detailsButton)
        } else if let annotation = annotation as? Arena {
            annotationTypeLabel.text = annotation.isEX ? "EX Arena" : "Arena"
            annotationImageView.image = annotation.image
            let raidButton = Button()
            let detailsButton = Button()
            raidButton.setTitle("Neuer Raid", for: .normal)
            raidButton.addTarget(self,
                                 action: #selector(DetailAnnotationView.showAnnotationSubmitDetailTapped(_:)),
                                 for: .touchUpInside)
            detailsButton.setTitle("Details", for: .normal)
            detailsButton.addTarget(self,
                                    action: #selector(DetailAnnotationView.showAnnotationInfoDetailTapped(_:)),
                                    for: .touchUpInside)
            buttonsStackView.addArrangedSubview(raidButton)
            buttonsStackView.addArrangedSubview(detailsButton)
        }
    }
    
    @objc
    func showAnnotationSubmitDetailTapped(_ sender: Any) {
        delegate?.showSubmitDetail(for: annotation)
    }
    
    @objc
    func showAnnotationInfoDetailTapped(_ sender: Any) {
        delegate?.showInfoDetail(for: annotation)
    }
}
