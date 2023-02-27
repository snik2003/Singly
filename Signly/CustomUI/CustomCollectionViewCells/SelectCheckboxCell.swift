//
//  SelectCheckboxCell.swift
//  Signly
//
//  Created by Сергей Никитин on 09.09.2022.
//

import UIKit

class SelectCheckboxCell: BaseCollectionViewCell {

    weak var form: SignatureForm?
    var model: CheckboxModel?
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    @IBAction func buttonAction() {
        guard let form = form else { return }
        guard let model = model else { return }
        
        backView.viewTouched {
            form.onChangeCheckbox(model)
        }
    }
}

extension SelectCheckboxCell {
    
    func configure(model: CheckboxModel, selected: Bool) {
        self.model = model
        
        self.backView.layer.cornerRadius = 12
        self.backView.backgroundColor = selected ? .appBackgroundColor : .clear
        self.backView.layer.borderColor = selected ? UIColor.appSystemColor.cgColor : UIColor.appSystemColor30.cgColor
        self.backView.layer.borderWidth = selected ? 2.0 : 1.0
        
        self.icon.image = model.image
    }
}
