//
//  SignColorCell.swift
//  Signly
//
//  Created by Сергей Никитин on 06.09.2022.
//

import UIKit

class SignColorCell: BaseCollectionViewCell {

    weak var delegate: AddSignatureViewController?
    weak var delegate2: FormPaintbrushCell?
    
    var model: SignatureColorModel?
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var button: UIButton!

    @IBAction func buttonAction() {
        guard let model = self.model else { return }
       
        if let delegate = delegate {
            guard model != delegate.penColor else { return }
        
            backView.viewTouched {
                delegate.onChangePenColor(model: model)
            }
        }
        
        if let delegate = delegate2 {
            guard let controller = delegate.delegate else { return }
            guard let form = controller.focusedForm else { return }
            
            backView.viewTouched {
                PaintbrushSettings.shared.color = model
                controller.presenter?.savePaintbrushColorSettings()
                delegate.collectionView.reloadData()
                delegate.scrollCollectionView()
                
                if form.type == .text {
                    form.textField.textColor = model.color
                    form.textField.tintColor = model.color
                    form.prepareAfterEditTextField(text: form.signText, showMenu: false)
                } else if form.type == .date {
                    form.textField.textColor = model.color
                    form.textField.tintColor = model.color
                    form.prepareAfterEditDate(showMenu: false)
                }
            }
        }
    }
}

extension SignColorCell {
    
    func configure(model: SignatureColorModel, selected: Bool) {
        self.model = model
        
        backView.backgroundColor = .clear
        backView.layer.cornerRadius = 13
        backView.layer.borderWidth = 2.0
        backView.layer.borderColor = selected ? model.color.cgColor : UIColor.clear.cgColor
        
        colorView.backgroundColor = model.color
        colorView.layer.cornerRadius = 10
    }
}
