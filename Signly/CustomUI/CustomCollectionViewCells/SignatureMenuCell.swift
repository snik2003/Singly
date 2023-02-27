//
//  SignatureMenuCell.swift
//  Signly
//
//  Created by Сергей Никитин on 08.09.2022.
//

import UIKit

class SignatureMenuCell: BaseCollectionViewCell {

    var delegate: SignatureForm?
    var model: SignatureMenuModel?
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var divider: UIView!
    
    @IBAction func buttonAction() {
        guard let delegate = delegate else { return }
        guard let model = self.model else { return }
        guard model != .divider else { return }
        
        button.viewTouched {
            delegate.menuActionFor(model)
        }
    }
}

extension SignatureMenuCell {
    
    func configure(model: SignatureMenuModel, selected: Bool) {
        self.model = model
        
        divider.backgroundColor = .white
        divider.layer.cornerRadius = 1.5
        divider.clipsToBounds = true
        divider.alpha = model == .divider ? 0.3 : 0.0
        
        button.tintColor = selected ? .appGoodStatusColor : .white
        button.setTitle("", for: .normal)
        button.setImage(model == .divider ? nil : model.icon, for: .normal)
    }
}
