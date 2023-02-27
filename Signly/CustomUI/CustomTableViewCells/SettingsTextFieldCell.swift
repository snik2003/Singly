//
//  SettingsTextFieldCell.swift
//  Signly
//
//  Created by Сергей Никитин on 04.09.2022.
//

import UIKit

class SettingsTextFieldCell: BaseTableCell {

    weak var delegate: SettingsViewController?
    var model: SettingsModel?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
}

extension SettingsTextFieldCell {
    
    func configure(model: SettingsModel, value: String? = nil) {
        self.model = model
        
        label.text = model.title
        label.textColor = .appDarkTextColor
        label.font = .appHeadline3
        
        textField.text = value == nil ? "" : value
        textField.tintColor = .appDarkTextColor
        textField.textColor = .appDarkTextColor
        textField.font = .appHeadline3
        
        textField.keyboardType = model == .email ? .emailAddress : .default
        textField.autocapitalizationType = model == .email ? .none : .words
        textField.textContentType = model == .name ? .name : model == .email ? .emailAddress : .organizationName
        
        textField.clearButtonMode = .never
        textField.setClearButtonImage()
        
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.appDarkTextColor30,
            NSAttributedString.Key.font : UIFont.appHeadline3
        ]
        textField.attributedPlaceholder = NSAttributedString(string: model.placeholder, attributes: attributes)
        textField.delegate = self
    }
}

extension SettingsTextFieldCell: UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let delegate = delegate else { return }
        guard let model = model else { return }
        
        let value = textField.text
        delegate.hideKeyboard()
        
        if model == .name {
            delegate.presenter?.setNameValue(value)
        } else if model == .email {
            delegate.presenter?.setEmailValue(value)
        } else if model == .company {
            delegate.presenter?.setCompanyValue(value)
        }
    }
}
