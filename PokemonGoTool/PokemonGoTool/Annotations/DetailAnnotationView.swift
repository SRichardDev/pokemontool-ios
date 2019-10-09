
import UIKit

class DetailAnnotationView: UIView {
    
    @IBOutlet private var annotationImageView: UIImageView!
    @IBOutlet private var annotationNameLabel: Label!
    @IBOutlet private var annotationDetailLabel: Label!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var buttonsStackView: UIStackView!
    
    var annotation: Annotation!
    weak var delegate: DetailAnnotationViewDelegate?
    
    func configure(with annotation: Annotation) {
        self.annotation = annotation
        annotationNameLabel.text = annotation.name
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 10
        
        if let pokestop = annotation as? Pokestop {
            let pokestopUtility = PokestopUtility(pokestop: pokestop)
            
            annotationDetailLabel.text = pokestopUtility.detailAnnotionString()
            annotationImageView.image = pokestopUtility.detailAnnotationImage()
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
        } else if let arena = annotation as? Arena {
            
            annotationDetailLabel.text = ArenaUtility.detailAnnotationString(for: arena)
            annotationImageView.image = ImageManager.combinedArenaImage(for: arena)
            
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
