
import UIKit

class SubmitNameViewController: UIViewController, UITextFieldDelegate {
    
    var submitContent: SubmitContent?
    var firebaseConnector: FirebaseConnector!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var buttonBottomToSuperViewConstraint: NSLayoutConstraint!
    @IBOutlet var exArenaTitleLabel: UILabel!
    @IBOutlet var exArenaSubtitleLabel: UILabel!
    @IBOutlet var isExSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.becomeFirstResponder()
        nameTextField.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        guard let submitType = submitContent?.submitType else { return }
        switch submitType {
        case .pokestop:
            exArenaTitleLabel.isHidden = true
            exArenaSubtitleLabel.isHidden = true
            isExSwitch.isHidden = true
        case .arena:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        submitContent?.name = nameTextField.text
        
        guard let submitType = submitContent?.submitType else { return }
        switch submitType {
        case .pokestop:
            break
        case .arena:
            submitContent?.submitType = .arena(isEX: isExSwitch?.isOn)
            break
        }
        
        if let destination = segue.destination as? SubmitCheckViewController {
            destination.submitContent = submitContent
            destination.firebaseConnector = firebaseConnector
        }
    }
    
    @objc
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            guard let submitType = submitContent?.submitType else { return }
            switch submitType {
            case .pokestop:
                buttonBottomToSuperViewConstraint.constant = keyboardHeight
            case .arena:
                break
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
