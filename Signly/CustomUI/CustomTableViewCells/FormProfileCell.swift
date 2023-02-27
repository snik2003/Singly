//
//  FormProfileCell.swift
//  Signly
//
//  Created by Сергей Никитин on 13.09.2022.
//

import UIKit

class FormProfileCell: BaseTableCell {

    weak var delegate: SigningViewController?
    var model: SettingsModel?
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    
    @IBAction func buttonAction() {
        guard let delegate = delegate else { return }
        guard let form = delegate.focusedForm else { return }
        guard let text = textField.text, !text.isEmpty else { return }
        
        backView.viewTouched {
            form.textField.text = text
            form.updateTextField(text: text)
            form.prepareAfterEditTextField(text: text, showMenu: false)
        }
    }
}

extension FormProfileCell {
    
    func configure(model: SettingsModel) {
        self.model = model
        
        backView.backgroundColor = .clear
        button.alpha = 1.0
        
        textField.backgroundColor = .clear
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor(red: 0.886, green: 0.89, blue: 0.894, alpha: 1).cgColor
        textField.textColor = .appDarkTextColor
        textField.font = .appHeadline3
        
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.keyboardAppearance = .light
        textField.returnKeyType = .done
        
        //textField.delegate = self
        textField.isUserInteractionEnabled = false
        
        nameLabel.text = model.title
        nameLabel.textColor = .appDarkTextColor60
        nameLabel.font = .appHintText
        
        guard let delegate = delegate else { return }
        
        switch model {
        case .name:
            textField.text = delegate.presenter?.nameValue()
        case .email:
            textField.text = delegate.presenter?.emailValue()
        case .company:
            textField.text = delegate.presenter?.companyValue()
        default:
            textField.text = ""
        }
    }
}

extension FormProfileCell: UITextFieldDelegate {
    
    @objc
    func textFieldTextDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        guard let delegate = delegate else { return }
        
        delegate.focusedForm.updateTextField(text: text)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let position = textField.endOfDocument
        textField.selectedTextRange = textField.textRange(from: position, to: position)
        
        guard let delegate = delegate else { return }
        guard let model = model else { return }
        
        UIView.animate(withDuration: delegate.animationDuration,
                       delay: 0.0,
                       options: UIView.AnimationOptions(rawValue: delegate.animationCurve),
                       animations: {
            delegate.toolbarViewHeightConstraint.constant += model.bottomInset
            delegate.toolbarViewBottomConstraint.constant = 10
            delegate.view.layoutIfNeeded()
        }, completion: { _ in })
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let delegate = delegate else { return }
        guard let model = model else { return }
        
        UIView.animate(withDuration: delegate.animationDuration,
                       delay: 0.0,
                       options: UIView.AnimationOptions(rawValue: delegate.animationCurve),
                       animations: {
            delegate.toolbarViewHeightConstraint.constant -= model.bottomInset
            delegate.toolbarViewBottomConstraint.constant = 10
            delegate.view.layoutIfNeeded()
        }, completion: { _ in })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let delegate = delegate else { return false }
        guard let form = delegate.focusedForm else { return false }
        guard let text = textField.text, !text.isEmpty else { return false }
        
        textField.resignFirstResponder()
        form.textField.text = text
        form.updateTextField(text: text)
        form.prepareAfterEditTextField(text: text, showMenu: false)
        delegate.textTableView.contentOffset = CGPoint(x: 0, y: 0)
        
        return true
    }
}
