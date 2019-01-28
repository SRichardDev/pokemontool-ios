
import UIKit

class SubmitNameViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var buttonBottomToSuperViewConstraint: NSLayoutConstraint!
    var submitContent: SubmitContent?
    var firebaseConnector: FirebaseConnector!

    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        submitContent?.name = nameTextField.text
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
            buttonBottomToSuperViewConstraint.constant = keyboardHeight
        }
    }
}
