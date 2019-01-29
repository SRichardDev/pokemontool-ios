
import UIKit

class SubmitNameViewController: UIViewController, UITextFieldDelegate {
    
    var viewModel: SubmitViewModel!
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
        exArenaTitleLabel.isHidden = viewModel.isPokestop
        exArenaSubtitleLabel.isHidden = viewModel.isPokestop
        isExSwitch.isHidden = viewModel.isPokestop
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if !viewModel.isPokestop {
            viewModel.submitType = .arena(isEX: isExSwitch?.isOn)
            viewModel.submitContent?.name = nameTextField.text
        }
        if let destination = segue.destination as? SubmitCheckViewController {
            destination.viewModel = viewModel
        }
    }
    
    @objc
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {            
            if viewModel.isPokestop {
                buttonBottomToSuperViewConstraint.constant = keyboardFrame.cgRectValue.height
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func tappedView(_ sender: Any) {
        nameTextField.resignFirstResponder()
    }
}
