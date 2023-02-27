//
//  SettingsButtonCell.swift
//  Signly
//
//  Created by Сергей Никитин on 04.09.2022.
//

import UIKit

class SettingsButtonCell: BaseTableCell {

    weak var delegate: SettingsViewController?
    var model: SettingsModel?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var button: UIButton!
    
    @IBAction func buttonAction() {
        guard let delegate = delegate else { return }
        guard let model = model else { return }
        
        backView.viewTouched {
            switch model {
            case .privacy:
                delegate.openPrivacyPolicy()
            case .terms:
                delegate.openTermsOfUse()
            case .contact:
                delegate.openContactDeveloperModule()
            default:
                break
            }
        }
    }
}

extension SettingsButtonCell {
    
    func configure(model: SettingsModel) {
        self.model = model
        self.backView.backgroundColor = .clear
        
        label.text = model.title
        label.textColor = .appDarkTextColor
        label.font = .appHeadline3
    }
}
