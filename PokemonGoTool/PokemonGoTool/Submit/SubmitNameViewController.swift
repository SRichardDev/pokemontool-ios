
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
        nameTextField.delegate = self
        nameTextField.text = viewModel.name
        exArenaTitleLabel.isHidden = viewModel.isPokestop
        exArenaSubtitleLabel.isHidden = viewModel.isPokestop
        isExSwitch.isHidden = viewModel.isPokestop
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        viewModel.name = nameTextField.text
        if !viewModel.isPokestop {
            viewModel.submitType = .arena(isEX: isExSwitch?.isOn)
        }
        if let destination = segue.destination as? SubmitCheckViewController {
            destination.viewModel = viewModel
        }
    }
    
    @objc
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            if viewModel.isPokestop {
                animateBottomButtonConstraint(to: keyboardFrame.cgRectValue.height)
            }
        }
    }
    
    @objc
    func keyboardWillHide(_ notification: Notification) {
        animateBottomButtonConstraint(to: 30)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nextButton.isEnabled = textField.text != ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        nextButton.isEnabled = textField.text != ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func tappedView(_ sender: Any) {
        nameTextField.resignFirstResponder()
    }
    
    private func animateBottomButtonConstraint(to constant: CGFloat) {
        buttonBottomToSuperViewConstraint.constant = constant
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
}
